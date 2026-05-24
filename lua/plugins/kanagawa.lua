return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = true,
      dimInactive = true,
      commentStyle = { italic = true },
      keywordStyle = { italic = false },
      statementStyle = { bold = true },
      functionStyle = {},
      typeStyle = {},
      colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette
        return {
          -- Floats: single bg (no two-tone), subtle visible border
          NormalFloat = { bg = theme.ui.bg_dim },
          FloatBorder = { fg = theme.ui.bg_p2, bg = theme.ui.bg_dim },
          FloatTitle = { fg = theme.ui.special, bg = theme.ui.bg_dim, bold = true },
          FloatFooter = { fg = theme.ui.nontext, bg = theme.ui.bg_dim },

          -- Treesitter context float
          TreesitterContext = { bg = theme.ui.bg_m1 },
          TreesitterContextLineNumber = { bg = theme.ui.bg_m1, fg = palette.peachRed },
          TreesitterContextBottom = {},

          -- Splits / separators flush with bg
          VertSplit = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          WinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          NeoTreeWinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },

          -- Mini
          MiniTrailspace = { bg = palette.samuraiRed },
          MiniCursorword = { bg = "#4A455F", underline = false, bold = false },
          MiniCursorwordCurrent = { bg = "#4A455F", underline = false, bold = false },

          -- Flash
          FlashBackdrop = { fg = theme.syn.comment, italic = false },
          FlashCurrent = { bg = palette.surimiOrange, fg = theme.ui.bg, bold = true },
          FlashLabel = { bg = palette.peachRed, fg = theme.ui.bg, bold = true },
          FlashMatch = { bg = palette.crystalBlue, fg = theme.ui.bg },
          FlashCursor = { reverse = true },

          -- Edgy winbar / titles (panel bg stays Normal — see edgy.lua winhighlight)
          EdgyWinBar = { fg = theme.ui.fg, bg = theme.ui.bg_m1, bold = true },
          EdgyWinBarNC = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          EdgyTitle = { fg = theme.ui.fg, bg = theme.ui.bg_m1, bold = true },
          EdgyIcon = { fg = palette.crystalBlue, bg = theme.ui.bg_m1 },
          EdgyIconActive = { fg = palette.surimiOrange, bg = theme.ui.bg_m1 },

          CursorLineNr = { fg = palette.surimiOrange },

          NoiceCmdlineIcon = { italic = false },
        }
      end,
    },
  },
}
