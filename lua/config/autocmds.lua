-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_user_command("Wa", "wa", { desc = "wall" })

vim.api.nvim_create_autocmd("InsertEnter", {
  group = vim.api.nvim_create_augroup("copilot_insert_hide", { clear = true }),
  callback = function() vim.b.copilot_suggestion_hidden = true end,
  desc = "Hide copilot suggestion on insert enter",
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown" },
  callback = function() vim.opt_local.conceallevel = 0 end,
})

-- Disable virtual text in JS/TS, re-enable for all other filetypes
local js_ts_fts = { javascript = true, typescript = true, typescriptreact = true }
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("js_ts_virtual_text", { clear = true }),
  callback = function(args)
    vim.diagnostic.config({ virtual_text = not js_ts_fts[vim.bo[args.buf].filetype] })
  end,
})
