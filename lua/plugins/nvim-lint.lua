local function eslint_config_exists()
  local configs = { ".eslintrc", ".eslintrc.json", ".eslintrc.js", ".eslintrc.cjs", "eslint.config.js" }
  for _, c in ipairs(configs) do
    if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. c) == 1 then
      return true
    end
  end
  return false
end

return {
  "mfussenegger/nvim-lint",
  event = "LazyFile",
  opts = {
    linters_by_ft = {
      javascript = eslint_config_exists() and { "eslint_d" } or {},
      typescript = eslint_config_exists() and { "eslint_d" } or {},
      sql = { "sqlfluff" },
    },
    linters = {
      eslint_d = {
        args = {
          "--config", vim.fn.getcwd() .. "/.eslintrc.cjs",
          "--stdin",
          "--stdin-filename",
          function() return vim.api.nvim_buf_get_name(0) end,
        },
      },
    },
  },
}
