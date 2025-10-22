return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = "markdown",
  enabled = vim.fn.has("win32") == 1,
  keys = {
    { "<leader>oo", "<cmd>Obsidian<cr>", desc = "Open Obsidian" },
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search in Obsidian" },
    { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Open Obsidian files" },
    { "<leader>od", "<cmd>ObsidianDailies<cr>", desc = "Open Daily Notes" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Open Today's Note" },
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = "Wicus",
        path = "G:\\My Drive\\Obsidian\\Wicus",
      },
    },
    notes_subdir = "Inbox",
    completion = {
      nvim_cmp = false,
      blink = true,
    },
    footer = { enabled = false, },
    statusline = { enabled = true },
    ui = { enable = false }
  },
}
