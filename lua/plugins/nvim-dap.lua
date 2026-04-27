local M = {}

M.lazy_specs = {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>",    function() require("dap").continue() end,                desc = "Start/Continue Debugging" },
      { "<F10>",   function() require("dap").step_over() end,               desc = "Step Over" },
      { "<F11>",   function() require("dap").step_into() end,               desc = "Step Into" },
      { "<S-F11>", function() require("dap").step_out() end,                desc = "Step Out" },
      { "<leader>dl", function() require("osv").launch({ port = 8086 }) end, desc = "Launch lua OSV server" },
    },
    config = function()
      M.dap_setup()
      M.csharp_dap_setup()
      M.lua_dap_setup()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "gk", function() require("dapui").eval() end,            desc = "DAP Eval", mode = { "n", "v" } },
      { "gl", function() require("dap").run_to_cursor() end,     desc = "Run to Cursor (Line)" },
    },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.4 },
            { id = "watches",     size = 0.2 },
            { id = "breakpoints", size = 0.2 },
            { id = "stacks",      size = 0.2 },
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
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = M.dapui_open
      dap.listeners.before.event_terminated["dapui_config"] = M.dapui_close
      dap.listeners.before.event_exited["dapui_config"] = M.dapui_close
    end,
  },
}

M._neotree_was_open = false

M.neotree_visible = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
      return true
    end
  end
  return false
end

M.dapui_open = function()
  local dapui = require("dapui")
  M._neotree_was_open = M.neotree_visible()
  if M._neotree_was_open then
    vim.cmd("Neotree close")
  end
  dapui.open()
end

M.dapui_close = function()
  require("dapui").close()
  if M._neotree_was_open then
    M._neotree_was_open = false
    vim.cmd("Neotree show")
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
  if not raw or #raw == 0 then return {} end
  local ok, data = pcall(vim.fn.json_decode, table.concat(raw, "\n"))
  if not ok or not data or not data.solution then return {} end

  local slnf_dir = vim.fn.fnamemodify(slnf_path, ":h")
  local sln_rel = data.solution.path and data.solution.path:gsub("\\", "/") or ""
  local sln_dir = vim.fn.fnamemodify(slnf_dir .. "/" .. sln_rel, ":h")

  local names = {}
  for _, proj_rel in ipairs(data.solution.projects or {}) do
    local csproj = sln_dir .. "/" .. proj_rel:gsub("\\", "/")
    if vim.fn.filereadable(csproj) == 1 then
      local src = table.concat(vim.fn.readfile(csproj), "\n")
      local is_exe = src:find('[Ee]xe</OutputType>') ~= nil
        or src:find('Sdk="Microsoft%.NET%.Sdk%.Web"') ~= nil
        or src:find("Sdk='Microsoft%.NET%.Sdk%.Web'") ~= nil
      if is_exe then
        local name = src:match('<AssemblyName>([^<]+)</AssemblyName>')
          or vim.fn.fnamemodify(csproj, ":t:r")
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
        local filtered = vim.tbl_filter(function(dll)
          return vim.tbl_contains(exe_names, vim.fn.fnamemodify(dll, ":t:r"))
        end, dlls)
        if #filtered > 0 then candidates = filtered end
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

-- Rider integration: only operates against an already-running Rider instance
-- that has the WSL-side solution open. Writes nvim-dap breakpoints into the
-- on-disk workspace.xml so Rider picks them up after a project reload.

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
    if parent == dir then break end
    dir = parent
  end
  return {}, nil
end

return M.lazy_specs
