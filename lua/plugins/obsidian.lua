local vault = vim.fn.expand("~/notes")

local function next_inbox_id()
  local date = os.date("%Y-%m-%d")
  local inbox = vault .. "/_inbox/"
  local i = 1
  while vim.uv.fs_stat(inbox .. date .. string.format("-%03d.md", i)) do
    i = i + 1
  end
  return date .. string.format("-%03d", i)
end

local function slugify(s)
  return s:lower():gsub("%s+", "-"):gsub("[^a-z0-9-]", "")
end

local function note_folders()
  local result = {}

  local function scan(dir, prefix)
    local entries = {}
    for name, type in vim.fs.dir(dir) do
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

  scan(vault)
  return result
end

local function backlinks()
  local path = vim.api.nvim_buf_get_name(0)
  if not vim.startswith(vim.fs.normalize(path), vim.fs.normalize(vault)) then
    vim.notify("Not in notes vault", vim.log.levels.WARN)
    return
  end

  local title = vim.fn.fnamemodify(path, ":t:r")
  local search = "\\[\\[" .. vim.pesc(title) .. "(\\||\\]\\])"
  Snacks.picker.grep({ cwd = vault, glob = "*.md", search = search, live = false, title = "Backlinks: " .. title })
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  event = {
    "BufReadPre " .. vault .. "/**.md",
    "BufNewFile " .. vault .. "/**.md",
  },
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  opts = {
    workspaces = { { name = "notes", path = vault } },
    notes_subdir = "_inbox",
    legacy_commands = false,
    link = { style = "wiki" },
    frontmatter = { enabled = false },
    note_id_func = function(title)
      if title and title ~= "" then
        return slugify(title)
      end
      return next_inbox_id()
    end,
    note_path_func = function(spec)
      return spec.dir / (spec.id .. ".md")
    end,
    templates = { enabled = false },
    picker = { name = "snacks" },
  },
  keys = {
    {
      "<leader>nn",
      -- empty string triggers next_inbox_id() date-based naming in note_id_func
      function() require("obsidian.actions").new("") end,
      desc = "Quick note",
    },
    {
      "<leader>nN",
      function()
        local title = vim.fn.input("Note title: ")
        if title == "" then return end
        vim.ui.select(note_folders(), { prompt = "Folder: " }, function(folder)
          if not folder then return end
          local path = vault .. "/" .. folder .. "/" .. slugify(title) .. ".md"
          if vim.fn.filereadable(path) == 0 then
            vim.fn.writefile({ "# " .. title, "" }, path)
          end
          vim.cmd.edit(vim.fn.fnameescape(path))
        end)
      end,
      desc = "New note",
    },
    { "<leader>nb", backlinks, desc = "Notes: backlinks" },
  },
}
