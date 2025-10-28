-- "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
-- "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
-- "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
-- "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
-- "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
-- CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      ["*"] = {
        keys = {
          { "gr", false },
          { "grr", function() Snacks.picker.lsp_references() end, desc = "LSP References" },
          { "gri", function() Snacks.picker.lsp_implementations() end, desc = "LSP Implementations" },
          { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP Type Definitions" },
          { "gd", function() Snacks.picker.lsp_definitions() end, desc = "LSP Definitions" },
          { "gh", vim.diagnostic.open_float, desc = "Show diagnostics" },
          { "<C-s>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature help" },

          -- Code Lens
          { "<leader>cc", function() vim.lsp.codelens.refresh() end, desc = "Refresh CodeLens" },
          { "<leader>cC", function() vim.lsp.codelens.clear() end, desc = "Clear CodeLens" },
        },
      },
    },
  },
}
