return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "3.35.1",
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
      commands = {
        add_to_git = function(state)
          local node = state.tree:get_node()
          if node and node.path then
            vim.cmd("!git add -f " .. vim.fn.shellescape(node.path))
            vim.cmd("redraw!") -- Refresh Neo-tree to reflect changes
          end
        end,
      },
    },
    window = {
      position = "left",
      width = 81,
      mappings = {
        ["/"] = "filter_on_submit",
        ["f"] = "fuzzy_finder",
        ["A"] = "add_to_git",
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.cmd("Neotree focus")
        end
      end,
      desc = "Open Neo-tree on startup",
    })
  end,
}
