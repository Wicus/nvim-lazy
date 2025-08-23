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

  local function read_jsonc(path)
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then
      return nil, "Cannot read " .. path
    end
    local content = table.concat(lines, "\n")
    -- strip /* */ and // comments
    content = content:gsub("/%*.-%*/", "")
    content = content:gsub("//[^\n]*", "")
    -- strip trailing commas
    content = content:gsub(",%s*([}%]])", "%1")
    local ok2, obj = pcall(vim.json.decode, content)
    if not ok2 then
      return nil, "Parse error in " .. path .. ": " .. tostring(obj)
    end
    return obj
  end

  local function get_launch_items(launch_path)
    local data, err = read_jsonc(launch_path)
    if not data then
      return nil, err
    end
    local configs = data.configurations
    if type(configs) ~= "table" then
      return nil, "No configurations in " .. launch_path
    end
    local items = {}
    for _, cfg in ipairs(configs) do
      if type(cfg) == "table" then
        table.insert(items, {
          name = cfg.name or "(unnamed)",
          cwd = cfg.cwd, -- may be nil
          preLaunchTask = cfg.preLaunchTask,
          cfg = cfg,
        })
      end
    end
    if #items == 0 then
      return nil, "No configurations found in " .. launch_path
    end
    return items
  end

  local function get_task_cwd(tasks_path, label)
    if not label then
      return nil
    end
    local data = read_jsonc(tasks_path)
    if not data or type(data.tasks) ~= "table" then
      return nil
    end
    for _, task in ipairs(data.tasks) do
      if type(task) == "table" and (task.label == label or task.taskName == label) then
        local opts = task.options
        if type(opts) == "table" and type(opts.cwd) == "string" then
          return opts.cwd
        end
      end
    end
    return nil
  end

  local function resolve_cwd(raw, ws)
    local dir = raw or "${workspaceFolder}"
    dir = dir:gsub("%${workspaceFolder}", ws)
    dir = dir:gsub("%${workspaceRoot}", ws)
    dir = dir:gsub("%${env:([%w_]+)}", function(var) return os.getenv(var) or "" end)
    -- Windows %VAR% style, just in case
    dir = dir:gsub("%%%s*([%w_]+)%s*%%", function(var) return os.getenv(var) or "" end)
    if not dir:match("^%a:[/\\]") and not dir:match("^/") then
      dir = ws .. "/" .. dir
    end
    dir = dir:gsub("[/\\]+", "/")
    return dir
  end

  vim.keymap.set("n", "<F4>", function()
    local ws = vim.fn.getcwd()
    local launch = ws .. "/.vscode/launch.json"
    local tasks = ws .. "/.vscode/tasks.json"

    local items, err = get_launch_items(launch)
    if not items then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    vim.ui.select(items, {
      prompt = "Select launch configuration to build",
      format_item = function(item)
        local hint = item.cwd or (item.preLaunchTask and ("task:" .. item.preLaunchTask)) or "${workspaceFolder}"
        return string.format("%s  [%s]", item.name, hint)
      end,
    }, function(choice)
      if not choice then
        return
      end

      -- Prefer task cwd if preLaunchTask is set; else use config cwd; else workspace
      local raw_cwd = get_task_cwd(tasks, choice.preLaunchTask) or choice.cwd or "${workspaceFolder}"
      local dir = resolve_cwd(raw_cwd, ws)

      if vim.fn.isdirectory(dir) == 0 then
        vim.notify("Build dir does not exist: " .. dir, vim.log.levels.ERROR)
        return
      end

      vim.notify("Building .NET project in " .. dir, vim.log.levels.INFO)
      vim.fn.jobstart({ "dotnet", "build" }, {
        cwd = dir,
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("dotnet build succeeded in " .. dir, vim.log.levels.INFO)
          else
            vim.notify(("dotnet build failed (code %d)"):format(code), vim.log.levels.ERROR)
          end
        end,
      })
    end)
  end, { desc = "Build .NET using cwd from selected launch configuration/task" })
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
