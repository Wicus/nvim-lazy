return {
  {
    "catppuccin/nvim",
    opts = {
      custom_highlights = function(colors)
        return {
          -- TreesitterContext = { bg = colors.mantle },
          -- TreesitterContextLineNumber = { bg = colors.mantle, fg = colors.red },
          -- TreesitterContextBottom = { style = {} },
          -- NormalFloat = { bg = colors.none },
          VertSplit = { fg = colors.mantle, bg = colors.mantle },
          -- MiniTrailspace = { bg = colors.red },
          -- FlashCurrent = { bg = colors.peach, fg = colors.base },
          -- FlashLabel = { bg = colors.red, bold = true, fg = colors.base },
          -- FlashMatch = { bg = colors.blue, fg = colors.base },
          -- FlashCursor = { reverse = true },
          NeoTreeWinSeparator = { fg = colors.mantle, bg = colors.mantle },
          -- CursorLineNr = { fg = colors.peach },
          -- TelescopePromptBorder = { fg = colors.rosewater },
          -- TelescopeTitle = { fg = colors.rosewater },
          SnacksIndent = { fg = "#313244" },
          SnacksIndentScope = { fg = "#6c7086" },
          MiniCursorword = { bg = "#45475a", style = {} },
          MiniCursorwordCurrent = { bg = "#45475a", style = {} },
          DiagnosticError = { style = {} },
          DiagnosticWarn = { style = {} },
          DiagnosticInfo = { style = {} },
          DiagnosticHint = { style = {} },
          DiagnosticOk = { style = {} },
          NoiceCmdlineIcon = { style = {} },
        }
      end,
    },
  },
}
