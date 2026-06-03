return {
  "rebelot/kanagawa.nvim",
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function() vim.opt_local.winhighlight = "Normal:TermNormal,NormalNC:TermNormalNC" end,
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
      local makeDiagnosticColor = function(color)
        local c = require("kanagawa.lib.color")
        return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
      end

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

        -- Dark completion
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },

        -- Diagnostics
        DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
        DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
        DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
        DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
      }
    end,
  },
}
