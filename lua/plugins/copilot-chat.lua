return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = {
    auto_insert_mode = false,
    model = "gpt-5",
    window = {
      layout = "float", -- 'vertical', 'horizontal', 'float'
      width = 0.65,
      height = 0.8,
      zindex = 100,
    },
  },
  keys = {
    {
      "<leader>am",
      "<cmd>CopilotChatModels<CR>",
      desc = "Select Model (CopilotChat)",
      mode = { "n", "v" },
    },
  },
  config = function(_, opts)
    local mappings = require("CopilotChat.config.mappings")
    mappings.reset.normal = "<leader>x"
    mappings.reset.insert = "<C-x>"
    require("CopilotChat").setup(vim.tbl_deep_extend("force", opts, { mappings = mappings }))
  end,
}
