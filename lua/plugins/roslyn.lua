return {
  "seblj/roslyn.nvim",
  ft = "cs",
  opts = { filewatching = "roslyn" },
  -- Server settings live here (not in autocmds.lua) so they are registered before
  -- the server starts; autocmds.lua loads on VeryLazy, which can be too late.
  init = function()
    vim.lsp.config("roslyn", {
      on_attach = function() vim.lsp.inlay_hint.enable(false) end,
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
        ["csharp|completion"] = {
          dotnet_show_completion_items_from_unimported_namespaces = true,
          dotnet_show_name_completion_suggestions = true,
        },
      },
    })
  end,
  keys = {
    { "<leader>lt", "<cmd>Roslyn target<cr>", desc = "LSP Roslyn (Select Target)" },
    { "<leader>ls", "<cmd>Roslyn stop<cr>", desc = "LSP Roslyn (Stop)" },
    { "<leader>lr", "<cmd>Roslyn restart<cr>", desc = "LSP Roslyn (Restart)" },
  },
}
