return {
  "folke/snacks.nvim",
  init = function()
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   group = vim.api.nvim_create_augroup("snacks_explorer_vim_enter", { clear = true }),
    --   callback = function() Snacks.picker.explorer() end,
    -- })
  end,
  opts = {
    indent = { enabled = false },
    words = { enabled = false },
    styles = {
      input = {
        relative = "cursor",
      },
      scratch = {
        width = 200,
        height = 60,
        zindex = 40,
      },
      lazygit = {
        height = 0.99,
        width = 0.99,
      },
      terminal = {
        style = "split",
      },
    },
    terminal = {
      integrations = {
        lazygit = {
          cmd = function()
            vim.cmd("tabnew") -- Open a new tab
            vim.cmd("term lazygit") -- Open lazygit in the new tab's terminal
          end,
        },
      },
      shell = "pwsh", -- shell to use for terminal
    },
    dashboard = {
      preset = {
        pick = nil,
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles', { filter = { cwd = true }})" },
          {
            icon = "󰈙 ",
            key = "e",
            desc = "Neotree Explorer",
            action = function()
              vim.cmd([[bdelete!]])
              require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
            end
          },
          {
            icon = "󰈙 ",
            key = "d",
            desc = "Vim Dadbod",
            action = function()
              vim.cmd([[bdelete!]])
              vim.cmd([[DBUI]])
            end
          },

          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "R", desc = "Old Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    picker = {
      win = {
        -- input window
        input = {
          keys = {
            ["H"] = { "toggle_hidden", mode = { "n" } },
            ["I"] = { "toggle_ignored", mode = { "n" } },
          },
        },
      },

      sources = {
        explorer = {
          enabled = false,
          layout = { layout = { preview = false, width = 82, zindex = 0 }, cycle = false },
          actions = {
            -- Just as an example
            avante_add_files = function(_, item)
              local relative_path = require("avante.utils").relative_path(item.file)
              local sidebar = require("avante").get()

              local open = sidebar:is_open()
              -- ensure avante sidebar is open
              if not open then
                require("avante.api").ask()
                sidebar = require("avante").get()
              end

              sidebar.file_selector:add_selected_file(relative_path)
            end,
            copy_path = function(_, item)
              local filename = vim.fn.fnamemodify(item.file, ":t")
              local values =
                { filename, item.file, vim.fn.fnamemodify(item.file, ":."), vim.fn.fnamemodify(item.file, ":r") }
              local items = { values[1], values[2], values[3], vim.fn.isdirectory(item.file) == 1 and values[4] or nil }

              vim.ui.select(items, { prompt = "Choose to copy to clipboard:" }, function(choice, i)
                if not choice then
                  vim.notify("Selection cancelled")
                  return
                end
                if not i then
                  vim.notify("Invalid selection")
                  return
                end
                local result = values[i]
                vim.fn.setreg("+", result) -- System clipboard
                vim.notify("Copied: " .. result)
              end)
            end,
          },
          win = {
            list = {
              keys = {
                ["-"] = "explorer_close",
                ["R"] = "explorer_update",
                ["`"] = "cd",
                ["~"] = "tcd",
                ["<leader>y"] = "copy_path",
                -- ["<leader>a"] = "avante_add_files",
              },
            },
          },
        },
      },
    },
  },
  keys = {
    -- Picker
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Live grep" },
    { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Grep cword" },
    { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Grep visual selection", mode = "x" },
    { "<leader>fr", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Find recent files" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>sl", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sj", function() Snacks.picker.lsp_symbols() end, desc = "LSP document symbols" },
    { "<leader>sb", function() Snacks.picker.grep_buffers() end, desc = "Search in buffer" },
    { "<leader>bb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>gg", function() Snacks.picker.git_status() end, desc = "Git status" },
    { "<leader>gs", enabled = false },
    { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle scratch buffer" },
    { "<leader>ss", function() Snacks.scratch.select() end, desc = "Select scratch buffer" },
    {
      "<leader>sn",
      function()
        local opts = { name = vim.fn.input("Name: ") }
        if opts.name ~= "" then
          Snacks.scratch.open(opts)
        end
      end,
      desc = "New scratch file",
    },
    -- keep this at the bottom, styling issues
    { "<M-e>", function() Snacks.terminal.toggle() end, desc = "Toggle terminal", mode = { "n", "t" } }, -- M-e is mapped to C-/ in WHK
  },
}
