local function sidekick_width() return math.max(45, math.min(140, math.floor(vim.o.columns * 0.45))) end

local config = {
  "folke/sidekick.nvim",
  opts = {
    nes = {
      enabled = false, -- Set to false to disable Next Edit Suggestions
    },
    cli = {
      ---@class sidekick.win.Opts
      win = {
        ---@type vim.api.keyset.win_config
        split = {
          width = sidekick_width(),
        },
        keys = {
          prompt = false,
          normal_mode = { "<Esc><Esc>", "stopinsert", mode = "t", desc = "enter normal mode" },
          passthrough_c_o = { "<c-o>", function(term) vim.api.nvim_chan_send(term.job, "\15") end, mode = "t" },
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "sidekick_terminal" then
            vim.api.nvim_win_set_width(win, sidekick_width())
          end
        end
      end,
      desc = "Resize Sidekick on terminal resize",
    })
  end,
  -- stylua: ignore
  keys = {
    {
      "<M-w>",
      function()
        require("sidekick.cli").toggle()
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Toggle"
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Toggle"
    },
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "claude" })
      end,
      mode = { "n", "x" },
      desc = "Sidekick: claude"
    },
    {
      "<leader>ax",
      function()
        require("sidekick.cli").toggle({ name = "codex" })
      end,
      mode = { "n", "x" },
      desc = "Sidekick: codex"
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").toggle({ name = "pi" })
      end,
      mode = { "n", "x" },
      desc = "Sidekick: pi"
    },
  },
}

local is_windows = vim.fn.has("win32") == 1
if is_windows then
  config.opts.cli.tools = config.opts.cli.tools or {}
  config.opts.cli.tools.codex = { cmd = { "wsl", "bash", "-ic", "codex" }, url = "https://github.com/openai/codex" }
end

return config
