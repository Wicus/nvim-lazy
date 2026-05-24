return {
  "rebelot/kanagawa.nvim",
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        vim.opt_local.winhighlight = "Normal:TermNormal,NormalNC:TermNormalNC"
      end,
    })
  end,
  opts = {
    compile = true,
    dimInactive = true,
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
    colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
    overrides = function(colors)
      local theme = colors.theme
      local palette = colors.palette

      return {
        TermNormal = { fg = theme.ui.fg, bg = theme.ui.bg_dim },
        TermNormalNC = { fg = theme.ui.fg_dim, bg = theme.ui.bg_dim },
        -- Splits / separators flush with bg
        VertSplit = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
        WinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },
        NeoTreeWinSeparator = { fg = theme.ui.bg_m3, bg = theme.ui.bg_m3 },

        -- Mini
        MiniCursorword = { bg = "#4A455F", underline = false, bold = false },
        MiniCursorwordCurrent = { bg = "#4A455F", underline = false, bold = false },

        -- Flash
        FlashBackdrop = { fg = theme.syn.comment, italic = false },

        NoiceCmdlineIcon = { italic = false },
      }
    end,
  },
}
