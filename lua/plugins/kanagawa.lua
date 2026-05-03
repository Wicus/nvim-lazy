return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = false },
      functionStyle = {},
      keywordStyle = { italic = false },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = theme.ui.bg_dim },
          FloatBorder = { bg = theme.ui.bg_dim },
          FloatTitle = { bg = theme.ui.bg_dim },
          NeoTreeWinSeparator = { fg = theme.ui.bg_dim, bg = theme.ui.bg_dim },
          DiagnosticVirtualTextError = { fg = theme.diag.error, italic = true },
          DiagnosticVirtualTextWarn = { fg = theme.diag.warning, italic = true },
          DiagnosticVirtualTextInfo = { fg = theme.diag.info, italic = true },
          DiagnosticVirtualTextHint = { fg = theme.diag.hint, italic = true },
          NoiceCmdlineIcon = {},
        }
      end,
      colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
    },
  },
}
