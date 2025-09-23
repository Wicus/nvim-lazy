return {
  "coder/claudecode.nvim",
  lazy = false,
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
    { "<leader>ac", "", desc = "+Claude Code", mode = { "n", "v" } },
    { "<M-w>", "<cmd>ClaudeCodeFocus<cr>", desc = "Toggle Claude Code", mode = { "n", "x" } }, -- M-w is mapped to C-. in WHK
    { "<leader>acr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>acC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>acm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>acb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>acs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>acs",
      "<cmd>ClaudeCodeTreeAdd<r>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },
    -- Diff management
    { "<leader>aca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>acd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
  opts = {
    terminal = {
      split_side = "right", -- "left" or "right"
      split_width_percentage = 0.40,
      snacks_win_opts = {
        keys = {
          claude_hide = { "<M-w>", function(self) self:hide() end, mode = "t", desc = "Hide" },
        },
      },
    },
  },
}
