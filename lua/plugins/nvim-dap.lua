local M = {}

M.lazy_specs = {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Start/Continue Debugging" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<F23>", function() require("dap").step_out() end, desc = "Step Out (S-F11 fallback)" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dl", function() require("osv").launch({ port = 8086 }) end, desc = "Launch lua OSV server" },
      { "<leader>dt", function() M.debug_dotnet_test() end, desc = "Debug .NET test under cursor", ft = "cs" },
    },
    config = function()
      M.dap_setup()
      M.csharp_dap_setup()
      M.lua_dap_setup()
      M.cpp_dap_setup()
      M.rust_dap_setup()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "gk", function() require("dapui").eval() end, desc = "DAP Eval", mode = { "n", "v" } },
      { "gl", function() require("dap").run_to_cursor() end, desc = "Run to Cursor (Line)" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>du", function() M.dapui_toggle() end, desc = "Toggle DAP UI" },
    },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.4 },
            { id = "watches", size = 0.2 },
            { id = "breakpoints", size = 0.2 },
            { id = "stacks", size = 0.2 },
          },
          position = "left",
          size = 60,
        },
        {
          elements = { { id = "repl", size = 1 } },
          position = "bottom",
          size = 12,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      opts.layouts[1].size = require("utils.ui").sidebar_width()
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = M.dapui_open
      dap.listeners.before.event_terminated["dapui_config"] = M.dapui_close
      dap.listeners.before.event_exited["dapui_config"] = M.dapui_close
    end,
  },
}

M._left_edge_was_open = false
M._sidekick_was_open = false
M._dapui_open = false

M.left_edge_visible = function()
  local layout = require("edgy.config").layout
  local left = layout and layout["left"]
  return left ~= nil and #left.wins > 0
end

M.sidekick_visible = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.w[win].sidekick_cli ~= nil then
      return true
    end
  end
  return false
end

M.dapui_open = function()
  M._left_edge_was_open = M.left_edge_visible()
  M._sidekick_was_open = M.sidekick_visible()
  if M._left_edge_was_open then
    vim.cmd("Neotree close")
  end
  if M._sidekick_was_open then
    require("sidekick.cli").toggle()
  end
  require("dapui").open()
  M._dapui_open = true
end

M.dapui_close = function()
  require("dapui").close()
  M._dapui_open = false
  if M._left_edge_was_open then
    M._left_edge_was_open = false
    require("edgy").open("left")
  end
  if M._sidekick_was_open then
    M._sidekick_was_open = false
    require("sidekick.cli").toggle()
  end
end

M.dapui_toggle = function()
  if M._dapui_open then
    M.dapui_close()
  else
    M.dapui_open()
  end
end

M.dap_setup = function()
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

-- Parse a .slnf to get (project_paths[], sln_base_dir).
-- Project paths in .slnf are relative to the .sln, not the .slnf.
M.slnf_exe_assembly_names = function(slnf_path)
  local raw = vim.fn.readfile(slnf_path)
  if not raw or #raw == 0 then
    return {}
  end
  local ok, data = pcall(vim.fn.json_decode, table.concat(raw, "\n"))
  if not ok or not data or not data.solution then
    return {}
  end

  local slnf_dir = vim.fn.fnamemodify(slnf_path, ":h")
  local sln_rel = data.solution.path and data.solution.path:gsub("\\", "/") or ""
  local sln_dir = vim.fn.fnamemodify(slnf_dir .. "/" .. sln_rel, ":h")

  local names = {}
  for _, proj_rel in ipairs(data.solution.projects or {}) do
    local csproj = sln_dir .. "/" .. proj_rel:gsub("\\", "/")
    if vim.fn.filereadable(csproj) == 1 then
      local src = table.concat(vim.fn.readfile(csproj), "\n")
      local is_exe = src:find("[Ee]xe</OutputType>") ~= nil
        or src:find('Sdk="Microsoft%.NET%.Sdk%.Web"') ~= nil
        or src:find("Sdk='Microsoft%.NET%.Sdk%.Web'") ~= nil
      if is_exe then
        local name = src:match("<AssemblyName>([^<]+)</AssemblyName>") or vim.fn.fnamemodify(csproj, ":t:r")
        table.insert(names, name)
      end
    end
  end
  return names
end

M.pick_dll = function()
  local co = coroutine.running()
  local cwd = vim.fn.getcwd()
  local dlls = vim.fn.globpath(cwd, "**/bin/Debug/**/*.dll", false, true)
  vim.list_extend(dlls, vim.fn.globpath(cwd, "**/bin/Release/**/*.dll", false, true))
  if #dlls == 0 then
    return vim.fn.input("Path to dll: ", cwd .. "/", "file")
  end

  -- filter by .slnf executable projects if available
  local candidates = dlls
  local slns = M.find_solutions()
  for _, sln in ipairs(slns) do
    if sln:match("%.slnf$") then
      local exe_names = M.slnf_exe_assembly_names(sln)
      if #exe_names > 0 then
        local filtered = vim.tbl_filter(
          function(dll) return vim.tbl_contains(exe_names, vim.fn.fnamemodify(dll, ":t:r")) end,
          dlls
        )
        if #filtered > 0 then
          candidates = filtered
        end
      end
      break
    end
  end

  -- sort by mtime: most recently built first
  table.sort(candidates, function(a, b)
    local sa, sb = vim.uv.fs_stat(a), vim.uv.fs_stat(b)
    return (sa and sa.mtime.sec or 0) > (sb and sb.mtime.sec or 0)
  end)

  -- auto-pick when unambiguous
  if #candidates == 1 then
    vim.notify("DLL: " .. vim.fn.fnamemodify(candidates[1], ":~:."), vim.log.levels.INFO)
    return candidates[1]
  end
  local s1, s2 = vim.uv.fs_stat(candidates[1]), vim.uv.fs_stat(candidates[2])
  if s1 and s2 and (s1.mtime.sec - s2.mtime.sec) > 5 then
    vim.notify("DLL: " .. vim.fn.fnamemodify(candidates[1], ":~:."), vim.log.levels.INFO)
    return candidates[1]
  end

  local items = vim.tbl_map(function(dll) return { text = dll, file = dll } end, candidates)
  Snacks.picker.pick({
    title = "Select DLL",
    items = items,
    format = "file",
    confirm = function(picker, item)
      picker:close()
      coroutine.resume(co, item and item.file or vim.fn.input("Path to dll: ", cwd .. "/", "file"))
    end,
  })
  return coroutine.yield()
end

M.debug_dotnet_test = function()
  local dap = require("dap")

  -- Find nearest test method name at or above cursor.
  local row = vim.fn.line(".")
  local test_name
  for i = row, 1, -1 do
    local line = vim.fn.getline(i)
    local name = line:match("public%s+async%s+Task%s+([%w_]+)%s*%(")
      or line:match("public%s+Task%s+([%w_]+)%s*%(")
      or line:match("public%s+void%s+([%w_]+)%s*%(")
    if name then
      test_name = name
      break
    end
  end
  if not test_name then
    test_name = vim.fn.input("Test name (FullyQualifiedName~...): ")
    if test_name == "" then
      return
    end
  end

  -- Walk up from current file to find owning .csproj.
  local dir = vim.fn.expand("%:p:h")
  local csproj
  while dir and dir ~= "/" do
    local found = vim.fn.glob(dir .. "/*.csproj", false, true)
    if #found > 0 then
      csproj = found[1]
      break
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  if not csproj then
    vim.notify("No .csproj found above current file", vim.log.levels.ERROR)
    return
  end

  vim.notify(("Launching test: %s"):format(test_name), vim.log.levels.INFO)

  local attached = false
  local function try_attach(line)
    if attached then
      return
    end
    local pid = line:match("Process Id:%s*(%d+)")
    if pid then
      attached = true
      vim.schedule(function()
        vim.notify(("Attaching to PID %s"):format(pid), vim.log.levels.INFO)
        dap.run({
          type = "netcoredbg",
          request = "attach",
          name = "Attach to dotnet test (auto)",
          processId = tonumber(pid),
        })
      end)
    end
  end

  vim.fn.jobstart({ "dotnet", "test", csproj, "--filter", "FullyQualifiedName~" .. test_name }, {
    env = { VSTEST_HOST_DEBUG = "1" },
    stdout_buffered = false,
    on_stdout = function(_, data)
      for _, line in ipairs(data or {}) do
        if line ~= "" then
          try_attach(line)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data or {}) do
        if line ~= "" then
          vim.schedule(function() vim.notify("[test stderr] " .. line, vim.log.levels.WARN) end)
        end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(
        function()
          vim.notify(
            ("dotnet test exited with code %d"):format(code),
            code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
          )
        end
      )
    end,
  })
end

M.csharp_dap_setup = function()
  local dap = require("dap")
  if not dap.adapters["netcoredbg"] then
    dap.adapters["netcoredbg"] = {
      type = "executable",
      command = vim.fn.exepath("netcoredbg"),
      args = { "--interpreter=vscode" },
      options = { detached = false },
    }
  end
  for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
    dap.configurations[lang] = {
      {
        type = "netcoredbg",
        name = "Launch file",
        request = "launch",
        program = M.pick_dll,
        args = function() return vim.split(vim.fn.input("Args: "), " ", { trimempty = true }) end,
        cwd = "${workspaceFolder}",
      },
      {
        type = "netcoredbg",
        name = "Attach to dotnet test (VSTEST_HOST_DEBUG)",
        request = "attach",
        processId = function()
          local pid = vim.fn.input("Test host PID: ")
          return tonumber(pid)
        end,
      },
    }
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

M.find_solutions = function()
  local dir = vim.fn.getcwd()
  while dir and dir ~= "/" do
    local slnf = vim.fn.glob(dir .. "/*.slnf", false, true)
    local sln = vim.fn.glob(dir .. "/*.sln", false, true)
    if #slnf > 0 or #sln > 0 then
      local out = {}
      vim.list_extend(out, slnf)
      vim.list_extend(out, sln)
      return out, dir
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  return {}, nil
end

M.cpp_dap_setup = function()
  local dap = require("dap")
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = { command = vim.fn.exepath("codelldb"), args = { "--port", "${port}" } },
  }
  for _, lang in ipairs({ "c", "cpp" }) do
    dap.configurations[lang] = {
      {
        type = "codelldb",
        request = "launch",
        name = "Launch",
        program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/", "file") end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end
end

-- Pick a cargo binary from target/debug/ — assumes you've run `cargo build` first.
-- For single-step "build then debug" use rustaceanvim's <leader>cd on a runnable instead.
M.pick_rust_binary = function()
  local cwd = vim.fn.getcwd()
  local debug_dir = cwd .. "/target/debug"
  if vim.fn.isdirectory(debug_dir) == 0 then
    vim.notify("No target/debug — run `cargo build` first", vim.log.levels.WARN)
    return vim.fn.input("Executable: ", cwd .. "/", "file")
  end

  local candidates = {}
  for _, path in ipairs(vim.fn.readdir(debug_dir)) do
    local full = debug_dir .. "/" .. path
    local stat = vim.uv.fs_stat(full)
    if stat and stat.type == "file" and vim.fn.executable(full) == 1 then
      table.insert(candidates, full)
    end
  end

  if #candidates == 0 then
    return vim.fn.input("Executable: ", debug_dir .. "/", "file")
  end
  if #candidates == 1 then
    return candidates[1]
  end

  table.sort(candidates, function(a, b)
    local sa, sb = vim.uv.fs_stat(a), vim.uv.fs_stat(b)
    return (sa and sa.mtime.sec or 0) > (sb and sb.mtime.sec or 0)
  end)

  local co = coroutine.running()
  local items = vim.tbl_map(function(p) return { text = p, file = p } end, candidates)
  Snacks.picker.pick({
    title = "Select Rust binary",
    items = items,
    format = "file",
    confirm = function(picker, item)
      picker:close()
      coroutine.resume(co, item and item.file or candidates[1])
    end,
  })
  return coroutine.yield()
end

M.rust_dap_setup = function()
  local dap = require("dap")
  -- Reuse codelldb adapter from cpp_dap_setup.
  dap.configurations.rust = {
    {
      type = "codelldb",
      request = "launch",
      name = "Launch cargo binary",
      program = M.pick_rust_binary,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = function() return vim.split(vim.fn.input("Args: "), " ", { trimempty = true }) end,
    },
  }
end

return M.lazy_specs
