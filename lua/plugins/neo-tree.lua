local ui = require("utils.ui")

local function is_starting_in_directory()
  if vim.fn.argc() ~= 1 then
    return false
  end

  local target = vim.fn.argv(0)
  return target ~= "" and vim.fn.isdirectory(target) == 1
end

-- Source of the open neo-tree window (nil when none is open).
local function neotree_source()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return vim.b[buf].neo_tree_source
    end
  end
  return nil
end

-- Swap the left panel between the file tree and git status in the same slot.
local function toggle_git_status()
  local neotree = require("neo-tree.command")
  if neotree_source() == "git_status" then
    neotree.execute({ source = "filesystem", action = "focus", position = "left", dir = vim.fn.getcwd() })
  else
    neotree.execute({ source = "git_status", action = "focus", position = "left", dir = LazyVim.root() })
  end
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
    { "<leader>ge", toggle_git_status, desc = "Git status (swap left panel)" },
  },
  opts = {
    close_if_last_window = true,
    sources = { "filesystem", "git_status" },
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
        if not node or not node.path then
          return
        end
        -- Inside herdr, send to the pinned agent pane; else sidekick terminal
        if vim.env.HERDR_PANE_ID then
          require("utils.cli_herdr").send_text("@" .. node.path)
          return
        end
        require("sidekick.cli").send({ msg = "@" .. node.path, submit = false })
      end,
      copy_to_notes = function(state)
        local node = state.tree:get_node()
        if node and node.path then
          require("utils.notes").copy_file_to_notes(node.path)
        end
      end,
      make_symlink = function(state)
        local node = state.tree:get_node()
        if not node or not node.path then
          return
        end
        local source = node.path
        local parent_dir = vim.fn.fnamemodify(source, ":h")
        vim.ui.input({
          prompt = "Symlink destination: ",
          default = parent_dir .. "/",
          completion = "file",
        }, function(dest)
          if not dest or dest == "" then
            return
          end
          dest = vim.fn.expand(dest)
          local result = vim.fn.system({ "ln", "-s", source, dest })
          if vim.v.shell_error ~= 0 then
            vim.notify("Symlink failed: " .. result, vim.log.levels.ERROR)
          else
            vim.notify("Symlink created: " .. dest .. " -> " .. source, vim.log.levels.INFO)
            require("neo-tree.sources.manager").refresh("filesystem")
          end
        end)
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
        ["L"] = "make_symlink",
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
          end, 50)
        end
      end,
      desc = "Open Neo-tree filesystem only on startup",
    })
    ui.autoresize_width("neo-tree", ui.sidebar_width)
  end,
}
