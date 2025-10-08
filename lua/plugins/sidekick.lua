return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      tools = {
        codex = { cmd = { "wsl", "bash", "-ic", "\"codex\"", "--search" }, url = "https://github.com/openai/codex" },
      },
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
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle({ name = "claude" }) end,
      desc = "Sidekick Select Prompt",
    },
    {
      "<M-w>",
      function() require("sidekick.cli").focus() end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
  },
}
