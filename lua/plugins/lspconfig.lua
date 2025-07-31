return {
  "neovim/nvim-lspconfig",
  opts = function()
    -- "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
    -- "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
    -- "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
    -- "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
    -- "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
    -- CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

    local keys = require("lazyvim.plugins.lsp.keymaps").get()

    keys[#keys + 1] = { "gr", false }
    keys[#keys + 1] = { "grr", function() Snacks.picker.lsp_references() end, desc = "LSP References" }
    keys[#keys + 1] = { "gri", function() Snacks.picker.lsp_implementations() end, desc = "LSP Implementations" }
    keys[#keys + 1] = { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP Type Definitions" }
    keys[#keys + 1] = { "gd", function() Snacks.picker.lsp_definitions() end, desc = "LSP Definitions" }
    keys[#keys + 1] = { "gh", vim.diagnostic.open_float, desc = "Show diagnostics" }
    keys[#keys + 1] = { "<C-s>", vim.lsp.buf.signature_help, desc = "Signature help" }
  end,
}
