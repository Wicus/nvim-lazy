return {
  "echasnovski/mini.trailspace",
  keys = {
    {
      "<leader>xw",
      function() require("mini.trailspace").trim() end,
      desc = "Trim trailing whitespace",
    },
  },
}
