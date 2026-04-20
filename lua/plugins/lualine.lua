local function is_sidekick_component(component)
  if type(component) ~= "table" then
    return false
  end

  for _, key in ipairs({ 1, "cond", "color" }) do
    local fn = component[key]
    local info = type(fn) == "function" and debug.getinfo(fn, "S") or nil
    local source = info and info.source or ""
    if source:find("lazyvim/plugins/extras/ai/sidekick.lua", 1, true) then
      return true
    end
  end

  return false
end

return {
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sections.lualine_x = vim.tbl_filter(function(component)
        return not is_sidekick_component(component)
      end, opts.sections.lualine_x or {})
    end,
  },
}
