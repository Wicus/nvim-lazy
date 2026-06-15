-- Send code context to a pinned tmux pane (e.g. a Claude Code session) running
-- in a sibling window of the SAME tmux session. Standalone, no sidekick.
--
-- Mechanics mirror sidekick.nvim's tmux backend:
--   tmux load-buffer  -b <buf> -          (stdin = rendered text)
--   tmux paste-buffer -b <buf> -d -r -t   (-r keeps \n raw so multiline doesn't submit)
--   tmux send-keys    -t <pane> Enter     (separate submit step, optional)
--
-- Assumes nvim and the target share a cwd (the typical "same project" setup),
-- so `@relpath` mentions resolve on the other side.

local M = {}

M.config = {
  auto_submit = false, -- press Enter in the target after pasting
  paste_buffer = "nvim-send",
}

---@type string? pinned tmux pane id, e.g. "%3"
M.target = nil

local PANE_FMT = "#{pane_id}\t#{window_index}\t#{window_name}\t#{pane_current_command}\t#{pane_current_path}"

local function in_tmux()
  if vim.env.TMUX then
    return true
  end
  vim.notify("Not inside a tmux session", vim.log.levels.ERROR)
  return false
end

---Run a tmux command synchronously. Returns stdout on success, nil on failure.
---@param args string[]
---@param opts? { stdin?: string, notify?: boolean }
local function tmux(args, opts)
  opts = opts or {}
  local cmd = { "tmux" }
  vim.list_extend(cmd, args)
  local res = vim.system(cmd, { text = true, stdin = opts.stdin }):wait()
  if res.code ~= 0 then
    if opts.notify ~= false then
      vim.notify("tmux failed: " .. (res.stderr or res.stdout or ""), vim.log.levels.ERROR)
    end
    return nil
  end
  return res.stdout or ""
end

---@class CliTmux.Pane
---@field id string
---@field window string
---@field name string
---@field cmd string
---@field cwd string

---List panes in the current tmux session, excluding nvim's own pane.
---@return CliTmux.Pane[]
local function panes()
  local out = tmux({ "list-panes", "-s", "-F", PANE_FMT })
  if not out then
    return {}
  end
  local self_pane = vim.env.TMUX_PANE
  local ret = {} ---@type CliTmux.Pane[]
  for line in vim.gsplit(out, "\n", { trimempty = true }) do
    local id, window, name, cmd, cwd = line:match("^([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t(.*)$")
    if id and id ~= self_pane then
      ret[#ret + 1] = { id = id, window = window, name = name, cmd = cmd, cwd = cwd }
    end
  end
  return ret
end

local function target_valid()
  if not M.target then
    return false
  end
  for _, pane in ipairs(panes()) do
    if pane.id == M.target then
      return true
    end
  end
  return false
end

---Pick (re-pin) the target pane, then optionally run `cb`.
---@param cb? fun()
function M.pick(cb)
  if not in_tmux() then
    return
  end
  local items = panes()
  if #items == 0 then
    vim.notify("No other tmux panes in this session", vim.log.levels.WARN)
    return
  end
  vim.ui.select(items, {
    prompt = "Send target (tmux pane):",
    -- aligned columns: window index · name · home-relative cwd
    format_item = function(pane)
      return ("%-3s %-14s %s"):format(pane.window, pane.name, vim.fn.fnamemodify(pane.cwd, ":~"))
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.target = choice.id
    vim.notify(("Send target → win %s:%s"):format(choice.window, choice.name))
    if cb then
      cb()
    end
  end)
end

---Ensure a valid target is pinned, then run `fn`.
---@param fn fun()
local function with_target(fn)
  if not in_tmux() then
    return
  end
  if target_valid() then
    return fn()
  end
  M.pick(fn)
end

---Paste arbitrary text into the pinned target.
---@param text string
function M.send_text(text)
  with_target(function()
    local buf = M.config.paste_buffer .. "-" .. M.target:gsub("%%", "")
    if not tmux({ "load-buffer", "-b", buf, "-" }, { stdin = text }) then
      return
    end
    tmux({ "paste-buffer", "-b", buf, "-d", "-r", "-t", M.target })
    if M.config.auto_submit then
      tmux({ "send-keys", "-t", M.target, "Enter" })
    end
  end)
end

---Path of the current buffer relative to cwd, or nil for a non-file buffer.
local function relpath()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return nil
  end
  return vim.fn.fnamemodify(name, ":.")
end

local function in_visual() return vim.fn.mode():match("[vV\22]") ~= nil end

---Whole-line visual range (only valid while in visual mode).
---@return integer srow, integer erow, string[] lines
local function visual_lines()
  local srow = vim.fn.getpos("v")[2]
  local erow = vim.fn.getpos(".")[2]
  if srow > erow then
    srow, erow = erow, srow
  end
  return srow, erow, vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
end

local function exit_visual()
  if in_visual() then
    vim.cmd("normal! \27")
  end
end

---`{this}`: a location reference. Range in visual mode, cursor line otherwise.
---@return string?
function M.this()
  local path = relpath()
  if in_visual() then
    local srow, erow = visual_lines()
    return path and ("@%s:L%d-%d"):format(path, srow, erow) or "this"
  end
  return path and ("@%s:L%d"):format(path, vim.fn.line(".")) or "this"
end

---`{file}`: the file reference.
---@return string?
function M.file()
  local path = relpath()
  if not path then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return nil
  end
  return "@" .. path
end

---`{selection}`: the visual selection as a fenced block with a location header.
---@return string?
function M.selection()
  if not in_visual() then
    vim.notify("Not in visual mode", vim.log.levels.WARN)
    return nil
  end
  local path = relpath()
  local srow, erow, lines = visual_lines()
  local header = path and ("@%s:L%d-%d"):format(path, srow, erow) or ""
  return table.concat({
    header,
    "```" .. (vim.bo.filetype or ""),
    table.concat(lines, "\n"),
    "```",
  }, "\n")
end

function M.send_this()
  local text = M.this()
  exit_visual()
  if text then
    M.send_text(text)
  end
end

function M.send_file()
  local text = M.file()
  if text then
    M.send_text(text)
  end
end

function M.send_selection()
  local text = M.selection()
  exit_visual()
  if text then
    M.send_text(text)
  end
end

return M
