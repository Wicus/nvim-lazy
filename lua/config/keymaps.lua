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

-- Send context to a pinned mux pane (e.g. a Claude session in a sibling
-- window). Backend picked by environment: herdr pane or tmux pane.
local cli_mux = function()
  return vim.env.HERDR_PANE_ID and require("utils.cli_herdr") or require("utils.cli_tmux")
end
vim.keymap.set({ "n", "x" }, "<leader>at", function() cli_mux().send_this() end, { desc = "Send this to mux pane" })
vim.keymap.set("n", "<leader>af", function() cli_mux().send_file() end, { desc = "Send file to mux pane" })
vim.keymap.set("x", "<leader>av", function() cli_mux().send_selection() end, { desc = "Send selection to mux pane" })
vim.keymap.set({ "n", "x" }, "<leader>aw", function() cli_mux().pick() end, { desc = "Pick mux send target" })

-- <C-h> (= <C-H>) deletes word in insert mode; in terminal mode it is window nav below
vim.keymap.set("i", "<C-H>", "<C-W>", { noremap = true, silent = true })

-- Seamless nvim<->mux pane navigation. Overrides LazyVim's <C-w>h defaults so
-- edge moves cross into mux panes. Mapped in n + t so it also works from
-- terminal buffers (incl. sidekick). Inside herdr, utils/herdr_nav hops to the
-- neighboring herdr pane at edges; inside tmux, vim-tmux-navigator does.
if vim.env.HERDR_PANE_ID then
  -- Pane-derived RPC socket so herdr's vim-nav.sh can call into this nvim
  -- (herdr intercepts C-hjkl globally and can't forward keys losslessly).
  -- Only claim it when no live nvim already owns it: transient nvims (git
  -- commit editor, quick edits, headless) inherit the same HERDR_PANE_ID and
  -- must not clobber the primary editor's socket — os.remove + rebind here
  -- would unlink the primary's file and orphan its listener, breaking C-hjkl.
  local sock = vim.fn.stdpath("run") .. "/herdr-nvim-" .. vim.env.HERDR_PANE_ID:gsub(":", "-") .. ".sock"
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
  local owned_by_live_nvim = ok and chan ~= 0
  if owned_by_live_nvim then
    pcall(vim.fn.chanclose, chan)
  else
    os.remove(sock)
    pcall(vim.fn.serverstart, sock)
  end

  -- Agents as herdr panes (replaces sidekick.nvim's CLI windows in herdr;
  -- sidekick's own keys are disabled in plugins/sidekick.lua for this env)
  local herdr_agent = require("utils.herdr_agent")
  vim.keymap.set({ "n", "x" }, "<leader>aa", function() herdr_agent.pick() end, { desc = "Agent: pick (herdr)" })
  vim.keymap.set({ "n", "x" }, "<leader>ac", function() herdr_agent.open("claude") end, { desc = "Agent: claude (herdr)" })
  vim.keymap.set({ "n", "x" }, "<leader>ax", function() herdr_agent.open("codex") end, { desc = "Agent: codex (herdr)" })
  vim.keymap.set({ "n", "x" }, "<leader>ap", function() herdr_agent.open("pi") end, { desc = "Agent: pi (herdr)" })

  local herdr_nav = require("utils.herdr_nav")
  vim.keymap.set({ "n", "t" }, "<C-h>", function() herdr_nav.navigate("left") end, { silent = true, desc = "Nav left (nvim/herdr)" })
  vim.keymap.set({ "n", "t" }, "<C-j>", function() herdr_nav.navigate("down") end, { silent = true, desc = "Nav down (nvim/herdr)" })
  vim.keymap.set({ "n", "t" }, "<C-k>", function() herdr_nav.navigate("up") end, { silent = true, desc = "Nav up (nvim/herdr)" })
  vim.keymap.set({ "n", "t" }, "<C-l>", function() herdr_nav.navigate("right") end, { silent = true, desc = "Nav right (nvim/herdr)" })
else
  vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true, desc = "Nav left (nvim/tmux)" })
  vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true, desc = "Nav down (nvim/tmux)" })
  vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Nav up (nvim/tmux)" })
  vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Nav right (nvim/tmux)" })
end

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
