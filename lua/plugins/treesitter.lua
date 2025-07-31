return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add tsx and treesitter
    vim.list_extend(opts.ensure_installed, {
      "c",
      "c_sharp",
      "cpp",
      "css",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "astro",
      "sql",
    })

    table.insert(opts.highlight.incremental_selection.highlight, {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>v",
          node_incremental = "v",
          node_decremental = "V",
          scope_incremental = "<C-s>",
        },
      },
    })
  end,
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true,
      max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
    },
  },
}
