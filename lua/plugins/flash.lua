return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        enabled = false,
      },
    },
  },
  keys = {
    { "s", enable = false, mode = { "n", "o", "x" } },
    { "S", enable = false, mode = { "n", "o", "x" } },
    {
      "f",
      function() require("flash").jump() end,
      desc = "Flash",
      mode = { "n", "o", "x" },
    },
    {
      "F",
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter",
      mode = { "n", "o", "x" },
    },
  },
}
