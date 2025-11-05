local config = {
  "folke/sidekick.nvim",
  opts = {
    nes = {
      enabled = false, -- Set to false to disable Next Edit Suggestions
    },
    cli = {
      tools = {
        codex = { cmd = { "codex", "resume" }, url = "https://github.com/openai/codex" }
      },
      ---@class sidekick.win.Opts
      win = {
        ---@type vim.api.keyset.win_config
        split = {
          width = 114,
        },
        keys = {
          stopinsert = { "<c-o>", "stopinsert", mode = "t" }, -- enter normal mode
          down = {
            "<C-n>",
            function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", false) end,
            mode = "t",
          },
          up = {
            "<C-p>",
            function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", false) end,
            mode = "t",
          },
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
      "<M-w>",
      function() require("sidekick.cli").toggle({ name = "codex" }) end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Toggle"
    },
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle({ name = "codex" }) end,
      mode = { "n", "x", },
      desc = "Sidekick Toggle"
    },
  },
}

local is_windows = vim.fn.has("win32") == 1
if is_windows then
  config.opts.cli.tools = config.opts.cli.tools or {}
  config.opts.cli.tools.codex =
    { cmd = { "wsl", "bash", "-ic", "codex", "resume" }, url = "https://github.com/openai/codex" }
end

return config
