-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Pasting will not replace the current register with what is selected
vim.keymap.set("x", "p", '"_dP', { desc = "Paste without copying replaced text" })

-- Copy to system clipboard
vim.keymap.set("x", "<C-c>", '"+y')

-- Move lines up and down with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keeps cursor on the same spot on K
vim.keymap.set("n", "J", "mzJ`z")

-- Keep centered while scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "*", "*zzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-i>", "<C-i>zz")
vim.keymap.set("n", "<C-o>", "<C-o>zz")
vim.keymap.set({ "x", "n" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "x", "n" }, "<leader>dd", function()
  vim.cmd("!rider " .. vim.fn.expand('%:p'))
end, { desc = "Open Rider Debugger" })
vim.keymap.set({ "x", "n" }, "<leader>dv", function()
  local file = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  local col  = vim.fn.col('.')
  vim.cmd([[!code . --reuse-window --goto ]] .. file .. ':' .. line .. ':' .. col)
end, { desc = "Open VSCode Debugger" })

vim.keymap.set({ "t" }, "<C-k>", "<cmd>close<cr>", { desc = "Close current window" })

Snacks.toggle
  .new({
    id = "diag_virtual_text",
    name = "Virtual Text",
    get = function() return vim.diagnostic.config().virtual_text ~= false end,
    set = function(state) vim.diagnostic.config({ virtual_text = state }) end,
  })
  :map("<leader>uv")
