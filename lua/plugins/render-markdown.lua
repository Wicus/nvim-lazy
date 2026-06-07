return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    ---@module "render-markdown"
    ---@type render.md.UserConfig
    opts = {
      file_types = { "markdown" },
      latex = { enabled = false },
    },
    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown buf_toggle<cr>",
        ft = "markdown",
        desc = "Toggle Inline Markdown Render",
      },
      {
        "<leader>mP",
        "<cmd>RenderMarkdown preview<cr>",
        ft = "markdown",
        desc = "Markdown Render Preview Split",
      },
    },
  },
}
