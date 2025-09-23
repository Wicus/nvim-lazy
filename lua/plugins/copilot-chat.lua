return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = {
    auto_insert_mode = false,
    model = "gpt-5",
    window = {
      layout = "vertical", -- 'vertical', 'horizontal', 'float'
      width = 0.40,
    },
  },
  keys = function()
    return {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ag", "", desc = "+Github Copilot Chat", mode = { "n", "v" } },
      {
        "<leader>agg",
        "<cmd>CopilotChatToggle<CR>",
        desc = "Toggle Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>agm",
        "<cmd>CopilotChatModels<CR>",
        desc = "Select Model (CopilotChat)",
        mode = { "n", "v" },
      },
    }
  end,
}
