return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      ---@class sidekick.win.Opts
      win = {
        ---@type vim.api.keyset.win_config
        split = {
          width = 80,
          height = 20,
        },
        keys = {
          stopinsert = { "<c-o>", "stopinsert", mode = "t" }, -- enter normal mode
        },
      },
      prompts = {
        commit_message = "Can you write a good git commit message for my changes and commit it?",
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>ap", enabled = false },
    {
      "<leader>aa",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<leader>ua",
      function() require("sidekick.cli").toggle() end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<M-w>",
      function() require("sidekick.cli").focus() end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
    -- Example of a keybinding to open Claude directly
    {
      "<leader>ac",
      function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
      desc = "Sidekick Claude Toggle",
    },
  },
}
