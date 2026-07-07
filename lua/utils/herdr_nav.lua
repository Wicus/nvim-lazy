-- Seamless nvim<->herdr pane navigation (vim-tmux-navigator equivalent).
-- Moves between nvim splits; at an edge, hops to the neighboring herdr pane.
-- herdr side: ~/.config/herdr/scripts/vim-nav.sh calls handle()/resize() over
-- RPC (socket registered in keymaps.lua) since herdr intercepts C-hjkl and
-- C-arrows globally and can't forward keys into nvim losslessly.

local M = {}

local wincmds = {
  left = "h",
  down = "j",
  up = "k",
  right = "l",
}

-- Raw keys per direction, fed back when nvim should handle the keypress
-- itself (e.g. <C-h> deletes a word in insert mode).
local nav_keys = {
  left = "<C-H>",
  down = "<C-J>",
  up = "<C-K>",
  right = "<C-L>",
}

local resize_keys = {
  left = "<C-Left>",
  down = "<C-Down>",
  up = "<C-Up>",
  right = "<C-Right>",
}

---Move focus in `direction`; hop to the herdr neighbor when at an nvim edge.
---@param direction "left"|"down"|"up"|"right"
function M.navigate(direction)
  local before = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(wincmds[direction])
  if vim.api.nvim_get_current_win() ~= before then
    return
  end
  vim.system({ "herdr", "pane", "focus", "--direction", direction, "--pane", vim.env.HERDR_PANE_ID })
end

---Entry point for herdr's C-hjkl bindings. Navigates in normal/terminal
---mode; in any other mode the original key is replayed so insert-mode
---<C-h> etc. keep their meaning (tmux passthrough parity).
---@param direction "left"|"down"|"up"|"right"
function M.handle(direction)
  local mode = vim.api.nvim_get_mode().mode
  if mode:find("^[nt]") then
    -- Schedule: --remote-expr runs in a restricted context (textlock)
    vim.schedule(function() M.navigate(direction) end)
    return
  end
  vim.api.nvim_input(nav_keys[direction])
end

---Entry point for herdr's C-arrow bindings: replay the key so nvim's own
---resize mappings apply.
---@param direction "left"|"down"|"up"|"right"
function M.resize(direction)
  vim.api.nvim_input(resize_keys[direction])
end

return M
