return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      return vim.b.completion;
    end,
    keymap = {
      preset = "enter",
      ["<M-q>"] = { "show", "show_documentation", "hide_documentation" }, -- "M-q" is remapped in AutoHotkey as <C-space>
      ["<M-/>"] = { function(cmp) cmp.show({ providers = { "snippets" } }) end },
    },
    completion = {
      ghost_text = {
        enabled = false,
      },
    },
    signature = { enabled = false },
  },
}
