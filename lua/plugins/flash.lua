return {
  "folke/flash.nvim",
  opts = {},
  keys = {
    -- Simulate nvim-treesitter incremental selection
    {
      "<leader>v",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter({
          actions = {
            ["v"] = "next",
            ["V"] = "prev",
          },
        })
      end,
      desc = "Treesitter Incremental Selection",
    },
  },
}
