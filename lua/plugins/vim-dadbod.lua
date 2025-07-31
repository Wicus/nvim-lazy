return {
  "kristijanhusak/vim-dadbod-ui",
  init = function()
    vim.g.db_ui_winwidth = 80
    vim.g.db_ui_execute_on_save = false

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("DBUIKeymaps", { clear = true }),
      pattern = "sql",
      callback = function() vim.keymap.set("n", "<F5>", "<Plug>(DBUI_ExecuteQuery)") end,
    })
  end,
}
