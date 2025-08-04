local M = {}

M.lazy_specs = {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Start/Continue Debugging" },
      { "<F6>", function() require("osv").launch({ port = 8086 }) end, desc = "Launch lua OSV server" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
    },
    config = function()
      M.dap_setup()
      M.csharp_dap_setup()
      M.lua_dap_setup()
      vim.cmd([[set noshellslash]])
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "gk", function() require("dapui").eval() end, desc = "DAP Eval", mode = { "n", "v" } },
      { "gl", function() require("dap").run_to_cursor() end, desc = "Run to Cursor (Line)" },
    },
    opts = {
      layouts = {
        {
          elements = {
            {
              id = "scopes",
              size = 0.25,
            },
            {
              id = "watches",
              size = 0.25,
            },
            {
              id = "stacks",
              size = 0.25,
            },
            {
              id = "breakpoints",
              size = 0.25,
            },
          },
          position = "left",
          size = 80,
        },
        {
          elements = {
            {
              id = "repl",
              size = 1,
            },
            -- I don't know what this actually does (in C# this does not do anything)
            -- {
            -- 	id = "console",
            -- 	size = 0.5,
            -- },
          },
          position = "bottom",
          size = 20,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = M.dapui_open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },
}

M.dapui_open = function()
  local dapui = require("dapui")
  local explorer_picker = require("snacks.picker").get({ source = "explorer" })
  if explorer_picker and explorer_picker[1] then
    explorer_picker[1]:close()
  end
  dapui.open()
end

M.dap_setup = function()
  -- load mason-nvim-dap here, after all adapters have been setup
  if LazyVim.has("mason-nvim-dap.nvim") then
    require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
  end

  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

  for name, sign in pairs(LazyVim.config.icons.dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define(
      "Dap" .. name,
      { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
    )
  end
end

M.csharp_dap_setup = function()
  local dap = require("dap")
  if not dap.adapters["netcoredbg"] then
    require("dap").adapters["netcoredbg"] = {
      type = "executable",
      command = vim.fn.exepath("netcoredbg"),
      args = { "--interpreter=vscode" },
      options = {
        detached = false,
      },
    }
  end
  for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
    if not dap.configurations[lang] then
      dap.configurations[lang] = {
        {
          type = "netcoredbg",
          name = "Launch file",
          request = "launch",
          ---@diagnostic disable-next-line: redundant-parameter
          program = function() return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file") end,
          cwd = "${workspaceFolder}",
        },
      }
    end
  end
end

M.lua_dap_setup = function()
  local dap = require("dap")
  dap.adapters.nlua = function(callback, config)
    callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
  end
  dap.configurations.lua = {
    {
      type = "nlua",
      request = "attach",
      name = "Attach to running Neovim instance",
    },
  }
end

return M.lazy_specs
