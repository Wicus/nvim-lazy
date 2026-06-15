-- Seamless C-hjkl navigation between nvim splits and tmux panes.
-- tmux side already configured in ~/.config/tmux/tmux.conf (is_vim passthrough).
-- Mappings are defined in lua/config/keymaps.lua so they override LazyVim's
-- default <C-w>h window maps (user keymaps load last). no_mappings stops the
-- plugin from setting its own, avoiding duplicates.
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  init = function() vim.g.tmux_navigator_no_mappings = 1 end,
}
