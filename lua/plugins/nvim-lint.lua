local eslint_configs = {
  ".eslintrc",
  ".eslintrc.json",
  ".eslintrc.js",
  ".eslintrc.cjs",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
}

return {
  "mfussenegger/nvim-lint",
  event = "LazyFile",
  opts = {
    linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      sql = { "sqlfluff" },
    },
    linters = {
      eslint_d = {
        -- Checked per lint run (LazyVim extension), searching upward from the
        -- file, so it works regardless of cwd and skips configless projects.
        condition = function(ctx) return vim.fs.find(eslint_configs, { path = ctx.filename, upward = true })[1] ~= nil end,
      },
    },
  },
}
