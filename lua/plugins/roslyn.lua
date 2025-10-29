return {
  "seblj/roslyn.nvim",
  ft = "cs",
  opts = { filewatching = "roslyn" },
  keys = {
    { "<leader>lt", "<cmd>Roslyn target<cr>", desc = "LSP Roslyn (Select Target)" },
    { "<leader>ls", "<cmd>Roslyn stop<cr>", desc = "LSP Roslyn (Stop)" },
    { "<leader>lr", "<cmd>Roslyn restart<cr>", desc = "LSP Roslyn (Restart)" },
  },
}
