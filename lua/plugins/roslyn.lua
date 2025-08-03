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
    { "<leader>lt", "<cmd>Roslyn target<cr>", desc = "LSP Roslyn (Select Target)" },
    { "<leader>ls", "<cmd>Roslyn stop<cr>", desc = "LSP Roslyn (Stop)" },
    { "<leader>lr", "<cmd>Roslyn restart<cr>", desc = "LSP Roslyn (Restart)" },
  },
}
