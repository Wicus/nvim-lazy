-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable / Disable backup files
vim.opt.swapfile = false
vim.opt.backup = true
vim.opt.backupdir = vim.fn.expand("~/nvim-lazy-backup-folder")

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 50

-- Color column
vim.opt.colorcolumn = "140"

-- Spelling
vim.opt.spell = false
vim.opt.spelllang = "en_us"

-- Clipboard
vim.opt.clipboard = ""

--  Set unknown filetypes
vim.filetype.add({ extension = { axaml = "xml" } })

-- <EOL> at the end of file will be restored if missing
vim.opt.fixendofline = false

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- LazyVim global options
vim.g.autoformat = false
vim.g.snacks_animate = false
vim.g.ai_cmp = false

