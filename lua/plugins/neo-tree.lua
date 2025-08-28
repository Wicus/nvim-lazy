return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>fe",
      function() require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() }) end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>fE",
      function() require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() }) end,
      desc = "Explorer NeoTree (Root Dir)",
    },
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
      mappings = {
        ["/"] = "filter_on_submit",
        ["f"] = "fuzzy_finder",
      },
    },
  },
}
