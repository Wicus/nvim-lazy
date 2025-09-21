return {
  {
    "nvim-mini/mini.cursorword",
    opts = {},
  },
  {
    "nvim-mini/mini.align",
    opts = {},
  },
  {
    "nvim-mini/mini.trailspace",
    keys = {
      {
        "<leader>xw",
        function() require("mini.trailspace").trim() end,
        desc = "Trim trailing whitespace",
      },
    },
  },
}
