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
    {
      "<leader>fo",
      function() require("neo-tree.command").execute({ reveal_force_cwd = true }) end,
      desc = "Explorer NeoTree (current file)",
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
            local stat = vim.uv.fs_stat(node.path)
            if not stat then
              vim.notify("Cannot stat " .. node.path, vim.log.levels.ERROR)
              return
            end

            if stat.type == "directory" then
              vim.notify("Cannot copy directory to notes", vim.log.levels.WARN)
              return
            end

            local dest = vim.fn.expand("~/projects/notes/") .. vim.fn.fnamemodify(node.path, ":t")
            local ok, err = vim.uv.fs_copyfile(node.path, dest)
            if not ok then
              vim.notify("Failed to copy to " .. dest .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
              return
            end

            vim.notify("Copied to " .. dest, vim.log.levels.INFO)
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
        ["N"] = "copy_to_notes",
        ["S"] = "send_to_sidekick",
        ["E"] = "open_in_explorer",
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
