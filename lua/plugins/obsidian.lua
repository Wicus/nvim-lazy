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

local folders = { "_inbox", "Projects", "Areas", "Resources", "Archives" }

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
      "<leader>on",
      -- empty string triggers next_inbox_id() date-based naming in note_id_func
      function() require("obsidian.actions").new("") end,
      desc = "Quick note",
    },
    {
      "<leader>oN",
      function()
        local title = vim.fn.input("Note title: ")
        if title == "" then return end
        vim.ui.select(folders, { prompt = "Folder: " }, function(folder)
          if not folder then return end
          local path = vault .. "/" .. folder .. "/" .. slugify(title) .. ".md"
          vim.cmd.edit(vim.fn.fnameescape(path))
          if vim.fn.filereadable(path) == 0 then
            vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. title, "" })
            vim.cmd("write")
          end
        end)
      end,
      desc = "New note",
    },
    { "<leader>ob", backlinks, desc = "Notes: backlinks" },
  },
}
