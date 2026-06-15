local M = {}

M.vault = vim.fn.expand("~/notes")

function M.next_inbox_id()
  local date = os.date("%Y-%m-%d")
  local inbox = M.vault .. "/_inbox/"
  local i = 1
  while vim.uv.fs_stat(inbox .. date .. string.format("-%03d.md", i)) do
    i = i + 1
  end
  return date .. string.format("-%03d", i)
end

function M.slugify(value) return value:lower():gsub("%s+", "-"):gsub("[^a-z0-9-]", "") end

function M.note_folders()
  local result = { "." }

  local function scan(dir, prefix)
    local ok, iter = pcall(vim.fs.dir, dir)
    if not ok or not iter then
      return
    end

    local entries = {}
    for name, type in iter do
      if type == "directory" and not vim.startswith(name, ".") then
        table.insert(entries, name)
      end
    end

    table.sort(entries)
    for _, name in ipairs(entries) do
      local rel = prefix and (prefix .. "/" .. name) or name
      table.insert(result, rel)
      scan(dir .. "/" .. name, rel)
    end
  end

  scan(M.vault)
  return result
end

function M.folder_path(folder)
  if not folder or folder == "." then
    return M.vault
  end
  return M.vault .. "/" .. folder
end

function M.select_folder(callback)
  if vim.fn.isdirectory(M.vault) == 0 then
    vim.notify("Notes vault missing: " .. M.vault, vim.log.levels.WARN)
    return
  end

  vim.ui.select(M.note_folders(), { prompt = "Folder: " }, function(folder)
    if not folder then
      return
    end
    callback(folder, M.folder_path(folder))
  end)
end

function M.unique_path(dir, filename)
  local path = dir .. "/" .. filename
  if not vim.uv.fs_stat(path) then
    return path
  end

  local stem = vim.fn.fnamemodify(filename, ":r")
  local ext = vim.fn.fnamemodify(filename, ":e")
  ext = ext ~= "" and ("." .. ext) or ""

  local i = 1
  repeat
    path = dir .. "/" .. stem .. string.format("-%03d", i) .. ext
    i = i + 1
  until not vim.uv.fs_stat(path)

  return path
end

function M.copy_file_to_notes(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    vim.notify("Cannot stat " .. path, vim.log.levels.ERROR)
    return
  end

  if stat.type == "directory" then
    vim.notify("Cannot copy directory to notes", vim.log.levels.WARN)
    return
  end

  M.select_folder(function(_, folder_path)
    local filename = vim.fn.fnamemodify(path, ":t")
    local dest = M.unique_path(folder_path, filename)
    local ok, err = vim.uv.fs_copyfile(path, dest)
    if not ok then
      vim.notify("Failed to copy to " .. dest .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
      return
    end

    vim.notify("Added note: " .. dest, vim.log.levels.INFO)
  end)
end

function M.copy_current_buffer_to_notes()
  if vim.bo.buftype ~= "" then
    vim.notify("Current buffer is not a file", vim.log.levels.WARN)
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Current buffer has no file name", vim.log.levels.WARN)
    return
  end

  M.select_folder(function(_, folder_path)
    local filename = vim.fn.fnamemodify(path, ":t")
    local dest = M.unique_path(folder_path, filename)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local ok = pcall(vim.fn.writefile, lines, dest)
    if not ok then
      vim.notify("Failed to write " .. dest, vim.log.levels.ERROR)
      return
    end

    vim.notify("Added note: " .. dest, vim.log.levels.INFO)
  end)
end

return M
