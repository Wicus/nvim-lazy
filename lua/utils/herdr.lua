-- Shared herdr CLI plumbing for utils/cli_herdr.lua and utils/herdr_agent.lua.

local M = {}

---Run a herdr command synchronously. Returns decoded JSON result on success.
---@param args string[]
---@return table?
function M.call(args)
  local cmd = { "herdr" }
  vim.list_extend(cmd, args)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify("herdr failed: " .. (res.stderr or res.stdout or ""), vim.log.levels.ERROR)
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, res.stdout or "")
  if not ok then
    return {}
  end
  if decoded.error then
    vim.notify("herdr failed: " .. (decoded.error.message or ""), vim.log.levels.ERROR)
    return nil
  end
  return decoded.result or {}
end

---Map of workspace_id → label, e.g. { ["w4"] = "home" }.
---@return table<string,string>
function M.workspace_labels()
  local result = M.call({ "workspace", "list" })
  local labels = {}
  for _, workspace in ipairs(result and result.workspaces or {}) do
    labels[workspace.workspace_id] = workspace.label
  end
  return labels
end

return M
