local ui = require("utils.ui")

local function is_starting_in_directory()
  if vim.fn.argc() ~= 1 then
    return false
  end

  local target = vim.fn.argv(0)
  return target ~= "" and vim.fn.isdirectory(target) == 1
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "<leader>E", false },
    {
      "<leader>e",
      function() require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() }) end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>fe",
      function() require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() }) end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>fE",
      function() require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() }) end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      "<leader>fo",
      function() require("neo-tree.command").execute({ reveal_force_cwd = true }) end,
      desc = "Explorer NeoTree (current file)",
    },
  },
  opts = {
    close_if_last_window = true,
    sources = { "filesystem", "git_status", "buffers" },
    source_selector = {
      winbar = false,
      statusline = false,
    },
    commands = {
      add_to_git = function(state)
        local node = state.tree:get_node()
        if node and node.path then
          vim.cmd("!git add -f " .. vim.fn.shellescape(node.path))
          vim.cmd("redraw!")
        end
      end,
      open_in_explorer = function(state)
        local node = state.tree:get_node()
        if node and node.path then
          local path = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
          if vim.fn.has("wsl") == 1 then
            local win_path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(path)):gsub("\n", "")
            vim.fn.jobstart({ "explorer.exe", win_path }, { detach = true })
          else
            vim.fn.jobstart({ "xdg-open", path }, { detach = true })
          end
        end
      end,
      send_to_sidekick = function(state)
        local node = state.tree:get_node()
        if node and node.path then
          require("sidekick.cli").send({ msg = "@" .. node.path, submit = false })
        end
      end,
      copy_to_notes = function(state)
        local node = state.tree:get_node()
        if node and node.path then
          require("utils.notes").copy_file_to_notes(node.path)
        end
      end,
    },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ["<bs>"] = "navigate_up",
          ["/"] = "filter_on_submit",
          ["f"] = "fuzzy_finder",
        },
      },
    },
    window = {
      position = "left",
      width = ui.sidebar_width(),
      mappings = {
        ["A"] = "add_to_git",
        ["N"] = "copy_to_notes",
        ["S"] = "send_to_sidekick",
        ["E"] = "open_in_explorer",
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        if vim.fn.argc() == 0 or is_starting_in_directory() then
          vim.defer_fn(function()
            require("neo-tree.command").execute({
              source = "filesystem",
              action = "focus",
              position = "left",
              dir = vim.fn.getcwd(),
            })
            require("neo-tree.command").execute({ source = "git_status", action = "close" })
            require("neo-tree.command").execute({ source = "buffers", action = "close" })
          end, 50)
        end
      end,
      desc = "Open Neo-tree filesystem only on startup",
    })
    ui.autoresize_width("neo-tree", ui.sidebar_width)
  end,
}
