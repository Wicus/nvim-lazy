-- Herdr-native replacement for sidekick.nvim's CLI windows. Agents (claude,
-- codex, pi) run as real herdr panes next to nvim instead of embedded
-- terminals: they persist across nvim restarts, show up in herdr's sidebar
-- with blocked/working/done state, and restore with the session.
--
-- open(name)  — focus the workspace's agent pane, creating it (split right
--               of nvim, ~45%) when missing. Come back with C-h.
-- send(...)   — context helpers live in utils/cli_herdr.lua (<leader>at/af/av).

local M = {}

M.config = {
  tools = { "claude", "codex", "pi" },
  -- share of the split the ORIGINAL (nvim) pane keeps
  nvim_ratio = 0.55,
}

local herdr = require("utils.herdr").call

---Find a pane running `name` in the current workspace, preferring nvim's tab.
---@param name string
---@return table? pane
local function find(name)
  local result = herdr({ "pane", "list", "--workspace", vim.env.HERDR_WORKSPACE_ID })
  if not result or not result.panes then
    return nil
  end
  local found = nil
  for _, pane in ipairs(result.panes) do
    if pane.agent == name then
      if pane.tab_id == vim.env.HERDR_TAB_ID then
        return pane
      end
      found = found or pane
    end
  end
  return found
end

---Focus the agent's pane, creating it next to nvim when missing.
---@param name string
function M.open(name)
  local pane = find(name)
  if pane then
    herdr({ "agent", "focus", pane.pane_id })
    return
  end
  local result = herdr({
    "pane", "split",
    "--pane", vim.env.HERDR_PANE_ID,
    "--direction", "right",
    "--ratio", tostring(M.config.nvim_ratio),
    "--cwd", vim.fn.getcwd(0),
    "--focus",
  })
  local new_pane = result and result.pane and result.pane.pane_id
  if not new_pane then
    vim.notify("herdr: could not create agent pane", vim.log.levels.ERROR)
    return
  end
  herdr({ "pane", "run", new_pane, name })
end

---Pick a running agent to attach to (any workspace), or start a new one.
function M.pick()
  local labels = require("utils.herdr").workspace_labels()
  local items = {} ---@type {text:string, pane_id?:string, tool?:string}[]
  local result = herdr({ "agent", "list" })
  for _, agent in ipairs(result and result.agents or {}) do
    items[#items + 1] = {
      pane_id = agent.pane_id,
      text = ("%-12s %-8s %-8s %s"):format(
        labels[agent.workspace_id] or agent.workspace_id,
        agent.agent,
        agent.agent_status,
        vim.fn.fnamemodify(agent.foreground_cwd or agent.cwd or "", ":~")
      ),
    }
  end
  for _, tool in ipairs(M.config.tools) do
    items[#items + 1] = { tool = tool, text = "new: " .. tool }
  end
  vim.ui.select(items, {
    prompt = "Agent (workspace · agent · status · cwd):",
    format_item = function(item) return item.text end,
  }, function(choice)
    if not choice then
      return
    end
    if choice.pane_id then
      herdr({ "agent", "focus", choice.pane_id })
      return
    end
    M.open(choice.tool)
  end)
end

return M
