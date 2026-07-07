return {
  "sindrets/diffview.nvim",
  lazy = false,
  config = function()
    local function files_to_qflist()
      local view = require("diffview.lib").get_current_view()
      if not view then return end

      local items = {}
      for _, file in view.files:iter() do
        table.insert(items, { filename = file.absolute_path, lnum = 1, col = 1, text = file.absolute_path })
      end

      if #items == 0 then
        vim.notify("diffview: no files", vim.log.levels.WARN)
        return
      end

      vim.fn.setqflist(items)
      vim.cmd("copen")
    end

    require("diffview").setup({
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
        },
        diff1 = {},
        diff2 = {},
        diff3 = {},
        diff4 = {},
        file_panel = {
          { "n", "q",     "<cmd>DiffviewClose<CR>", { desc = "Close" } },
          { "n", "<C-q>", files_to_qflist,          { desc = "Send all files to quickfix" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
        },
        option_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
        },
        help_panel = {},
      },
    })
  end,
  keys = {
    { "<leader>gs", "<cmd>DiffviewOpen<CR>",          desc = "Git Diff" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "Git File History" },
  },
}
