-- Send code context to a pinned herdr pane (e.g. a Claude Code session) in
-- the current herdr session. Mirror of utils/cli_tmux.lua for herdr.
--
-- Mechanics:
--   herdr pane send-text <pane_id> <text>   (literal text, no submit — raw \n
--                                            inserts newlines like tmux
--                                            paste-buffer -r)
--   herdr pane send-keys <pane_id> enter    (separate submit step, optional)
--
-- Assumes nvim and the target share a cwd (the typical "same project" setup),
-- so `@relpath` mentions resolve on the other side.

local M = {}

M.config = {
  auto_submit = false, -- press Enter in the target after sending
}

---@type string? pinned herdr pane id, e.g. "w4:p5"
M.target = nil

local function in_herdr()
  if vim.env.HERDR_PANE_ID then
    return true
  end
  vim.notify("Not inside a herdr session", vim.log.levels.ERROR)
  return false
end

local herdr = require("utils.herdr").call

---@class CliHerdr.Pane
---@field id string
---@field workspace string label of the containing workspace
---@field tab string
---@field agent string
---@field cwd string

---List panes in the herdr session, excluding nvim's own pane.
---@return CliHerdr.Pane[]
local function panes()
  local result = herdr({ "pane", "list" })
  if not result or not result.panes then
    return {}
  end
  local labels = require("utils.herdr").workspace_labels()
  local self_pane = vim.env.HERDR_PANE_ID
  local ret = {} ---@type CliHerdr.Pane[]
  for _, pane in ipairs(result.panes) do
    if pane.pane_id ~= self_pane then
      ret[#ret + 1] = {
        id = pane.pane_id,
        workspace = labels[pane.workspace_id] or pane.workspace_id,
        tab = pane.tab_id,
        agent = pane.agent or "shell",
        cwd = pane.foreground_cwd or pane.cwd or "",
      }
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
  if not in_herdr() then
    return
  end
  local items = panes()
  if #items == 0 then
    vim.notify("No other herdr panes in this session", vim.log.levels.WARN)
    return
  end
  vim.ui.select(items, {
    prompt = "Send target (herdr pane):",
    -- aligned columns: workspace · agent · home-relative cwd
    format_item = function(pane)
      return ("%-12s %-10s %s"):format(pane.workspace, pane.agent, vim.fn.fnamemodify(pane.cwd, ":~"))
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.target = choice.id
    vim.notify(("Send target → %s (%s)"):format(choice.workspace, choice.agent))
    if cb then
      cb()
    end
  end)
end

---Ensure a valid target is pinned, then run `fn`.
---@param fn fun()
local function with_target(fn)
  if not in_herdr() then
    return
  end
  if target_valid() then
    return fn()
  end
  M.pick(fn)
end

---Send arbitrary text into the pinned target.
---@param text string
function M.send_text(text)
  with_target(function()
    if not herdr({ "pane", "send-text", M.target, text }) then
      return
    end
    if M.config.auto_submit then
      herdr({ "pane", "send-keys", M.target, "enter" })
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
