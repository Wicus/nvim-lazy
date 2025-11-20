return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      cs = { "csharpier", lsp_format = "fallback" },
      json = { "prettierd" },
      python = { "black" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      html = { "prettierd" },
    },
  },
  keys = {
    {
      "<leader>f=",
      function() require("conform").format({ timeout_ms = 5000 }) end,
      mode = { "n", "v" },
      desc = "Format",
    },
  },
}
