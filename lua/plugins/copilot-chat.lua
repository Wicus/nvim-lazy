return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = {
    auto_insert_mode = false,
    -- model = 'claude-3.7-sonnet',
    model = "gpt-4.1",
    window = {
      layout = "float", -- 'vertical', 'horizontal', 'float'
      width = 0.6,
      height = 0.8,
    },
    -- window = {
    --   width = 0.33,
    -- },
  },
  keys = {
    {
      "<leader>am",
      "<cmd>CopilotChatModels<CR>",
      desc = "Select Model (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      function() return require("CopilotChat").reset() end,
      desc = "Clear (CopilotChat)",
      mode = { "n", "v" },
    },
  },
}
