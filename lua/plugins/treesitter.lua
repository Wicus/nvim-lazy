return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "c_sharp" })

    opts.incremental_selection = vim.tbl_deep_extend("force", opts.incremental_selection, {
      enable = true,
      keymaps = {
        init_selection = "<leader>v",
        node_incremental = "v",
        node_decremental = "V",
        scope_incremental = "<C-s>",
      },
    })
  end,
}
