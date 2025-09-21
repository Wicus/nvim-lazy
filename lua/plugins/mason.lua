return {
  "mason-org/mason.nvim",
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:crashdummyy/mason-registry",
    },
    ensure_installed = { "stylua", "csharpier", "prettierd", "black", "netcoredbg", "roslyn", "eslint_d" },
  },
}
