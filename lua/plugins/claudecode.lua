-- Custom Claude Code Integration Plugin
local M = {}

local state = {
  terminal_buf = nil,
  terminal_win = nil,
  terminal_tab = nil,
  is_active = false,
  esc_timer = nil,
}

local config = {
  claude_cmd = "claude",
  tab_name = "Claude Code",
}

-- Terminal management - consolidated into one function
function M.toggle()
  local current_tab = vim.api.nvim_get_current_tabpage()

  -- Find existing Claude tab
  local claude_tab = nil
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab].tabname == config.tab_name then
      claude_tab = tab
      break
    end
  end

  -- If on Claude tab, hide it
  if state.is_active and current_tab == claude_tab then
    local tabs = vim.api.nvim_list_tabpages()
    for _, tab in ipairs(tabs) do
      if tab ~= claude_tab then
        vim.api.nvim_set_current_tabpage(tab)
        break
      end
    end
    state.is_active = false
    return
  end

  -- Show or create Claude terminal
  if claude_tab then
    vim.api.nvim_set_current_tabpage(claude_tab)
    local wins = vim.api.nvim_tabpage_list_wins(claude_tab)
    if #wins > 0 then
      vim.api.nvim_set_current_win(wins[1])
      state.terminal_buf = vim.api.nvim_win_get_buf(wins[1])
    end
  else
    -- Check Claude CLI availability
    local handle = io.popen("where claude 2>nul")
    local claude_available = false
    if handle then
      local result = handle:read("*a")
      handle:close()
      claude_available = result and result:match("%S") ~= nil
    end

    if not claude_available then
      vim.notify("Claude CLI not found. Install: npm install -g @anthropic-ai/claude-cli", vim.log.levels.ERROR)
      return
    end

    -- Create new terminal tab
    vim.cmd("tabnew")
    vim.t.tabname = config.tab_name
    vim.cmd("terminal " .. config.claude_cmd)

    state.terminal_tab = vim.api.nvim_get_current_tabpage()
    state.terminal_buf = vim.api.nvim_get_current_buf()
    state.terminal_win = vim.api.nvim_get_current_win()
    vim.bo[state.terminal_buf].buflisted = false

    -- Setup keymaps
    local opts = { buffer = state.terminal_buf }
    vim.keymap.set("t", "<esc>", function()
      state.esc_timer = state.esc_timer or (vim.uv or vim.loop).new_timer()
      if state.esc_timer:is_active() then
        state.esc_timer:stop()
        vim.cmd("stopinsert")
      else
        state.esc_timer:start(200, 0, function() end)
        return "<esc>"
      end
    end, vim.tbl_extend("force", opts, { expr = true, desc = "Double escape to normal mode" }))

    vim.keymap.set("t", "<M-w>", M.toggle, vim.tbl_extend("force", opts, { desc = "Toggle Claude Code" }))
  end

  vim.cmd("startinsert")
  state.is_active = true
end

-- Send content to Claude terminal - consolidated function
function M.send_to_claude(content_type, data)
  -- Ensure terminal exists
  if not state.terminal_buf or not vim.api.nvim_buf_is_valid(state.terminal_buf) then
    M.toggle()
  end

  -- Switch to terminal tab if needed
  if state.terminal_tab then
    vim.api.nvim_set_current_tabpage(state.terminal_tab)
  end

  local cmd
  if content_type == "file" then
    local relative_path = vim.fn.fnamemodify(data, ":.")
    cmd = "@" .. relative_path .. "\r"
  elseif content_type == "text" then
    cmd = data .. "\r"
  end

  if cmd then
    vim.api.nvim_chan_send(vim.bo[state.terminal_buf].channel, cmd)
  end
end

-- Add current buffer or specified file
function M.add_file(filepath)
  local file_path = filepath or vim.fn.expand("%:p")
  if file_path == "" then
    vim.notify("No file to add", vim.log.levels.WARN)
    return
  end
  M.send_to_claude("file", file_path)
end

-- Add selected text with context
function M.add_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  -- Handle partial selections
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local relative_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
  local message = string.format("Selected from @%s (lines %d-%d):\n\n```\n%s\n```",
    relative_path, start_pos[2], end_pos[2], table.concat(lines, "\n"))

  M.send_to_claude("text", message)
end

-- Setup and return plugin spec
return {
  name = "claude-code",
  dev = true,
  dir = vim.fn.stdpath("config"),
  config = function()
    -- User commands
    vim.api.nvim_create_user_command("ClaudeToggle", M.toggle, { desc = "Toggle Claude Code terminal" })
    vim.api.nvim_create_user_command("ClaudeAddFile", function(opts)
      M.add_file(opts.args ~= "" and opts.args or nil)
    end, { desc = "Add file to Claude Code", nargs = "?", complete = "file" })
    vim.api.nvim_create_user_command("ClaudeAddSelection", M.add_selection, {
      desc = "Add selected text to Claude Code", range = true
    })

    -- Cleanup
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        if state.esc_timer then
          state.esc_timer:stop()
          state.esc_timer:close()
        end
      end
    })
  end,
  keys = {
    { "<M-w>", M.toggle, desc = "Toggle Claude Code", mode = { "n", "x", "t" } },
    { "<leader>aa", M.add_file, desc = "Add current buffer to Claude" },
    { "<leader>aa", M.add_selection, desc = "Add selected text to Claude", mode = "x" },
    {
      "<leader>aa",
      function()
        local success, neo_tree = pcall(require, "neo-tree.sources.manager")
        if success then
          local neo_state = neo_tree.get_state("filesystem")
          local node = neo_state.tree:get_node()
          if node and node.path then
            M.add_file(node.path)
          else
            vim.notify("No file selected in Neo-tree", vim.log.levels.WARN)
          end
        else
          vim.notify("Neo-tree not available", vim.log.levels.ERROR)
        end
      end,
      desc = "Add file from Neo-tree to Claude",
      ft = { "neo-tree" }
    },
  }
}