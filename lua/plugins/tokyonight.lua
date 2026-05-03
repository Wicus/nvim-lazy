return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        hl.NoiceCmdlineIcon = {}
        hl.NeoTreeGitConflict = { fg = c.orange, bold = true }
        hl.NeoTreeGitUntracked = { fg = c.magenta }
        hl.DiagnosticVirtualTextError = { fg = c.error, italic = true }
        hl.DiagnosticVirtualTextWarn = { fg = c.warning, italic = true }
        hl.DiagnosticVirtualTextInfo = { fg = c.info, italic = true }
        hl.DiagnosticVirtualTextHint = { fg = c.hint, italic = true }

        require("utils.highlights").disable_keyword_italic(hl, { "vim" })
      end,
    },
  },
}
