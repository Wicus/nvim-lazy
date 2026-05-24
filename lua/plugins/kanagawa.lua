return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      overrides = function(colors)
        local theme = colors.theme
        return {
          MiniCursorword = { bg = "#4A455F", underline = false, bold = false },
          MiniCursorwordCurrent = { bg = "#4A455F", underline = false, bold = false },
          FlashBackdrop = { fg = theme.syn.comment, italic = false },
          VertSplit = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          WinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
          NeoTreeWinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
        }
      end,
    },
  },
}
