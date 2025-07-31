return {
  "seblj/roslyn.nvim",
  ft = "cs",
  opts = {
    filewatching = "roslyn",
    choose_target = function(target)
      return vim.iter(target):find(function(item)
        if string.match(item, "IoTnxt.Eskom.V5.sln") then
          return item
        end
      end)
    end,
  },
  keys = {
    { "<leader>rt", "<cmd>Roslyn target<cr>", desc = "Roslyn Select Target" },
    { "<leader>rs", "<cmd>Roslyn stop<cr>", desc = "Roslyn Stop" },
    { "<leader>rr", "<cmd>Roslyn restart<cr>", desc = "Roslyn Restart" },
  },
}
