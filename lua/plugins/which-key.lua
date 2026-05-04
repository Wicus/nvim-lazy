return {
  "folke/which-key.nvim",
  opts = {
    preset = "classic",
    delay = 0, -- show immediately; v3 no longer uses timeoutlen for this
    spec = {
      {
        { "<leader>l", group = "lsp", icon = "󰒋" },
        { "<leader>n", group = "notes", icon = "󰎞" },
        { "gr", group = "lsp", icon = "", },
      },
    },
  },
}
