return {
  "stevearc/oil.nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  keys = {
    { "-", function() require("oil.actions").parent.callback() end, desc = "Oil" },
  },
  opts = {
    keymaps = {
      ["q"] = "actions.close",
      ["g-"] = function()
        require("oil.actions").tcd.callback()
        vim.cmd("silent !explorer .")
      end,
      ["<C-h>"] = false,
      ["<C-j>"] = false,
      ["<C-k>"] = false,
      ["<C-l>"] = false,
    },
  },
}
