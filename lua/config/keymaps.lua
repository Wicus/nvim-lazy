-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Note: x-mode "paste without copying replaced text" lives in plugins/yanky.lua (p/P)

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
vim.keymap.set(
  { "x", "n" },
  "<leader>or",
  function() vim.cmd("!rider " .. vim.fn.expand("%:p")) end,
  { desc = "Open in Rider" }
)
vim.keymap.set({ "x", "n" }, "<leader>ov", function()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  vim.cmd([[!code . --reuse-window --goto ]] .. file .. ":" .. line .. ":" .. col)
end, { desc = "Open in VSCode" })

-- Send context to a pinned tmux pane (e.g. a Claude session in a sibling window)
local cli_tmux = function() return require("utils.cli_tmux") end
vim.keymap.set({ "n", "x" }, "<leader>at", function() cli_tmux().send_this() end, { desc = "Send this to tmux" })
vim.keymap.set("n", "<leader>af", function() cli_tmux().send_file() end, { desc = "Send file to tmux" })
vim.keymap.set("x", "<leader>av", function() cli_tmux().send_selection() end, { desc = "Send selection to tmux" })
vim.keymap.set({ "n", "x" }, "<leader>aw", function() cli_tmux().pick() end, { desc = "Pick tmux send target" })

-- <C-h> (= <C-H>) deletes word in insert mode; in terminal mode it is window nav below
vim.keymap.set("i", "<C-H>", "<C-W>", { noremap = true, silent = true })

-- Seamless nvim<->tmux pane navigation (christoomey/vim-tmux-navigator).
-- Overrides LazyVim's <C-w>h defaults so edge moves cross into tmux panes.
-- Mapped in n + t so it also works from terminal buffers (incl. sidekick).
vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true, desc = "Nav left (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true, desc = "Nav down (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Nav up (nvim/tmux)" })
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Nav right (nvim/tmux)" })

Snacks.toggle
  .new({
    id = "diag_virtual_text",
    name = "Virtual Text",
    get = function() return vim.diagnostic.config().virtual_text ~= false end,
    set = function(state) vim.diagnostic.config({ virtual_text = state }) end,
  })
  :map("<leader>uv")

Snacks.toggle
  .new({
    id = "harper_ls",
    name = "Harper LSP",
    get = function() return vim.lsp.is_enabled("harper_ls") end,
    set = function(state)
      if state then
        require("lazy").load({ plugins = { "nvim-lspconfig" } })
      end
      vim.lsp.enable("harper_ls", state)
      if state and vim.lsp.config.harper_ls then
        local cfg = vim.deepcopy(vim.lsp.config.harper_ls)
        cfg.name = "harper_ls"
        if not cfg.filetypes or vim.tbl_contains(cfg.filetypes, vim.bo.filetype) then
          vim.lsp.start(cfg, { bufnr = 0, silent = true })
        end
      end
    end,
  })
  :map("<leader>uH")

Snacks.toggle({
  name = "Completion",
  get = function() return vim.b.completion end,
  set = function(state) vim.b.completion = state end,
}):map("<leader>uq")
