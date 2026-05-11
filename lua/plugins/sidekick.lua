local PROMPT_DIR = vim.fs.normalize(vim.fn.stdpath("state") .. "/sidekick-prompts")

local function prompt_path()
  local safe = vim.fn.getcwd():gsub("[/\\:]", "%%")
  return PROMPT_DIR .. "/" .. safe .. ".md"
end

local function sidekick_width()
  return math.max(45, math.min(140, math.floor(vim.o.columns * 0.45)))
end

local function prompt_height()
  return math.max(10, math.floor(vim.o.lines * 0.30))
end

local function find_prompt_buf()
  local path = prompt_path()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) == path then return buf end
  end
end

local function find_prompt_win()
  local buf = find_prompt_buf()
  if not buf then return end
  local wins = vim.fn.win_findbuf(buf)
  return wins[1]
end

local function get_or_create_prompt_buf()
  local buf = find_prompt_buf()
  if buf then return buf end
  local path = prompt_path()
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({}, path)
  end
  buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = true
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local start = 0
      for i = #lines, 1, -1 do
        if lines[i] == "---" then
          start = i
          break
        end
      end
      local seg = vim.list_slice(lines, start + 1, #lines)
      local msg = vim.trim(table.concat(seg, "\n"))
      if msg == "" then
        vim.notify("sidekick prompt: empty", vim.log.levels.WARN)
        return
      end
      require("sidekick.cli").ask({ msg = msg, submit = true })
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "---", "", "" })
      vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), vim.api.nvim_buf_get_name(buf))
      vim.bo[buf].modified = false
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end,
  })
  return buf
end

local function open_prompt()
  local buf = get_or_create_prompt_buf()
  local win = find_prompt_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("belowright " .. prompt_height() .. "split")
    vim.api.nvim_win_set_buf(0, buf)
    vim.wo.winfixheight = true
  end
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 0 })
  vim.cmd("startinsert!")
end

local function toggle_prompt()
  local win = find_prompt_win()
  if win then
    vim.api.nvim_win_close(win, false)
  else
    open_prompt()
  end
end

local function append_to_prompt(lines)
  local buf = get_or_create_prompt_buf()
  local cur = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #cur > 0 and cur[#cur] ~= "" then
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
  end
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
  if not find_prompt_win() then open_prompt() end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
  end
end

local function add_selection()
  local mode = vim.fn.mode()
  local s, e = vim.fn.getpos("v"), vim.fn.getpos(".")
  local sel = vim.fn.getregion(s, e, { type = mode })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  if not sel or #sel == 0 then return end
  local file = vim.fn.expand("%:.")
  local s_line, e_line = math.min(s[2], e[2]), math.max(s[2], e[2])
  local ft = vim.bo.filetype
  local out = { string.format("`%s:%d-%d`", file, s_line, e_line), "```" .. ft }
  vim.list_extend(out, sel)
  table.insert(out, "```")
  append_to_prompt(out)
end

local function add_file_ref()
  local file = vim.fn.expand("%:.")
  if file == "" then return end
  append_to_prompt({ "@" .. file })
end

local config = {
  "folke/sidekick.nvim",
  opts = {
    nes = {
      enabled = false, -- Set to false to disable Next Edit Suggestions
    },
    cli = {
      ---@class sidekick.win.Opts
      win = {
        ---@type vim.api.keyset.win_config
        split = {
          width = sidekick_width(),
        },
        keys = {
          prompt = false,
          passthrough_c_o = { "<c-o>", function(term) vim.api.nvim_chan_send(term.job, "\15") end, mode = "t" },
        },
      }
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local prompt = prompt_path()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "sidekick_terminal" then
            vim.api.nvim_win_set_width(win, sidekick_width())
          elseif vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) == prompt then
            vim.api.nvim_win_set_height(win, prompt_height())
          end
        end
      end,
      desc = "Resize Sidekick on terminal resize",
    })
  end,
  -- stylua: ignore
  keys = {
    {
      "<M-w>",
      function()
        require("sidekick.cli").toggle()
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Toggle"
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      mode = { "n", "x", },
      desc = "Sidekick Toggle"
    },
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "claude" })
      end,
      mode = { "n", "x", },
      desc = "Sidekick: claude"
    },
    {
      "<leader>ax",
      function()
        require("sidekick.cli").toggle({ name = "codex" })
      end,
      mode = { "n", "x", },
      desc = "Sidekick: codex"
    },
    { "<leader>ai", toggle_prompt, mode = { "n" },        desc = "Sidekick: prompt buffer" },
    { "<leader>av", add_selection, mode = "x",            desc = "Sidekick: add selection" },
    { "<leader>aF", add_file_ref,  mode = "n",            desc = "Sidekick: add file ref"  },
  },
}

local is_windows = vim.fn.has("win32") == 1
if is_windows then
  config.opts.cli.tools = config.opts.cli.tools or {}
  config.opts.cli.tools.codex =
    { cmd = { "wsl", "bash", "-ic", "codex" }, url = "https://github.com/openai/codex" }
end

return config
