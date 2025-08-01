return {
  "zbirenbaum/copilot.lua",
  keys = {
    {
      "<leader>uc",
      function() require("copilot.suggestion").toggle_auto_trigger() end,
      desc = "Copilot",
    },
    {
      "<C-j>",
      function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").next()
        else
          vim.b.copilot_suggestion_hidden = false
          require("copilot.suggestion").dismiss()
          require("copilot.suggestion").next()
        end
      end,
      mode = { "i" },
    },
    {
      "<C-l>",
      function()
        if require("copilot.suggestion").is_visible() then
          require("copilot.suggestion").accept()
        end
      end,
      mode = { "i" },
    },
  },
}
