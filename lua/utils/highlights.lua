local M = {}

local function fg_of(hl, group, depth)
  depth = depth or 0
  if depth > 5 then return nil end
  local h = hl[group]
  if not h then return nil end
  if h.link then return fg_of(hl, h.link, depth + 1) end
  return h.fg
end

local DEFAULT_KEYWORD_GROUPS = {
  "@keyword",
  "@keyword.function",
  "@keyword.return",
  "@keyword.conditional",
  "@keyword.repeat",
  "@keyword.operator",
  "@keyword.coroutine",
  "@keyword.import",
}

--- Disable italic on keyword treesitter captures for the given languages.
--- Preserves the existing fg by following links up to `Keyword`.
function M.disable_keyword_italic(hl, langs, groups)
  groups = groups or DEFAULT_KEYWORD_GROUPS
  for _, lang in ipairs(langs) do
    for _, g in ipairs(groups) do
      local fg = fg_of(hl, g) or fg_of(hl, "Keyword")
      hl[g .. "." .. lang] = { fg = fg, italic = false }
    end
  end
end

return M
