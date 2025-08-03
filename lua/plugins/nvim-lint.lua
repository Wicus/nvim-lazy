return {
  "mfussenegger/nvim-lint",
  event = "LazyFile",
  opts = {
    linters_by_ft = {
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      sql = { "sqlfluff" },
    },
  },
}
