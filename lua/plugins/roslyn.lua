return {
  "seblj/roslyn.nvim",
  ft = "cs",
  opts = { filewatching = "roslyn" },
  -- Server settings live here (not in autocmds.lua) so they are registered before
  -- the server starts; autocmds.lua loads on VeryLazy, which can be too late.
  init = function()
    -- roslyn.nvim (main) resolves the `roslyn-language-server` launcher and, when
    -- missing, falls back to a bare `Microsoft.CodeAnalysis.LanguageServer` not on
    -- PATH. The pinned 5.4.0 server (see plugins/mason.lua) only ships the raw-dll
    -- `roslyn` bin, which the slim launcher cmd doesn't drive: it needs --logLevel
    -- and --extensionLogDirectory. Override cmd to the raw bin with those args;
    -- when the modern launcher is present, leave the plugin default (cmd = nil).
    local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
    local cmd = nil
    if vim.fn.executable(vim.fs.joinpath(mason_bin, "roslyn-language-server")) == 0 then
      local raw_bin = vim.fs.joinpath(mason_bin, "roslyn")
      if vim.fn.executable(raw_bin) == 1 then
        local log_dir = vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn")
        vim.fn.mkdir(log_dir, "p")
        cmd = { raw_bin, "--stdio", "--logLevel", "Information", "--extensionLogDirectory", log_dir }
      end
    end
    vim.lsp.config("roslyn", {
      cmd = cmd,
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
