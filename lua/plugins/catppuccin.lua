return {
  {
    "catppuccin/nvim",
    opts = {
      color_overrides = {
        all = {},
        latte = {},
        frappe = {},
        macchiato = {},
        mocha = {},
      },
      custom_highlights = function(colors)
        return {
          TreesitterContext = { bg = colors.mantle },
          TreesitterContextLineNumber = { bg = colors.mantle, fg = colors.red },
          TreesitterContextBottom = { style = {} },
          VertSplit = { fg = colors.mantle, bg = colors.mantle },
          MiniTrailspace = { bg = colors.red },
          FlashCurrent = { bg = colors.peach, fg = colors.base },
          FlashLabel = { bg = colors.red, bold = true, fg = colors.base },
          FlashMatch = { bg = colors.blue, fg = colors.base },
          FlashCursor = { reverse = true },
          NeoTreeWinSeparator = { fg = colors.mantle, bg = colors.mantle },
          CursorLineNr = { fg = colors.peach },
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
