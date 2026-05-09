return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux/Win Left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux/Win Down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux/Win Up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux/Win Right" },
  },
}
