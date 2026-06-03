local function neotree_width() return math.max(20, math.min(81, math.floor(vim.o.columns * 0.25))) end

local function is_starting_in_directory()
  if vim.fn.argc() ~= 1 then
    return false
  end

  local target = vim.fn.argv(0)
  return target ~= "" and vim.fn.isdirectory(target) == 1
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "3.35.1",
  keys = {
    { "<leader>e", false },
    { "<leader>E", false },
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
    sources = { "filesystem", "git_status" },
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

          local dest = vim.fn.expand("~/notes/_inbox/") .. vim.fn.fnamemodify(node.path, ":t")
          local ok, err = vim.uv.fs_copyfile(node.path, dest)
          if not ok then
            vim.notify("Failed to copy to " .. dest .. ": " .. (err or "unknown error"), vim.log.levels.ERROR)
            return
          end

          vim.notify("Copied to " .. dest, vim.log.levels.INFO)
        end
      end,
    },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ["/"] = "filter_on_submit",
          ["f"] = "fuzzy_finder",
        },
      },
    },
    window = {
      position = "left",
      width = neotree_width(),
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
          require("edgy").open("left")
          vim.defer_fn(function()
            require("neo-tree.command").execute({ source = "filesystem", position = "left", dir = vim.uv.cwd() })

            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "neo-tree" and vim.b[buf].neo_tree_source == "filesystem" then
                vim.api.nvim_set_current_win(win)
                return
              end
            end
          end, 50)
        end
      end,
      desc = "Open Neo-tree filesystem + git_status via edgy on startup",
    })
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "neo-tree" then
            vim.api.nvim_win_set_width(win, neotree_width())
          end
        end
      end,
      desc = "Resize Neo-tree on terminal resize",
    })
  end,
}
