return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "<leader>fE", false },
    { "<leader>E", false },
  },
  opts = {
    close_if_last_window = true,
    sources = { "filesystem", "buffers", "git_status" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 81,
    },
  },
}
