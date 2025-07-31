-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Pasting will not replace the current register with what is selected
vim.keymap.set("x", "p", '"_dP')

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

-- Execute lua code
vim.keymap.set("n", "<leader>rf", "<cmd>source %<cr>", { desc = "Reload (Source) file" })
vim.keymap.set("v", "<leader>r", ":lua<cr>", { desc = "Reload (Execute lua)" })
vim.keymap.set("n", "<leader>r", "<cmd>.lua<cr>", { desc = "Reload (Execute lua)" })

-- Tab navigation
vim.keymap.set("n", "]t", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "[t", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
