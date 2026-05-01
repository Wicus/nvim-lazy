return {
  {
    "folke/tokyonight.nvim",
    opts = {
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
      on_highlights = function(hl, c)
        hl.DiagnosticError = { fg = c.error }
        hl.DiagnosticWarn = { fg = c.warning }
        hl.DiagnosticInfo = { fg = c.info }
        hl.DiagnosticHint = { fg = c.hint }
        hl.DiagnosticOk = { fg = c.teal }
        hl.NoiceCmdlineIcon = {}
        hl.NeoTreeGitConflict = { fg = c.orange, bold = true }
        hl.NeoTreeGitUntracked = { fg = c.magenta }
      end,
    },
  },
}
