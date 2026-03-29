return {
  "mason-org/mason.nvim",
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:crashdummyy/mason-registry",
    },
    ensure_installed = {
      "stylua",
      "csharpier",
      "prettierd",
      "black",
      "netcoredbg",
      -- This is the last working version before 5.6: 5.4.0-2.26175.10 and the mason registry does not have it in it's registry. 
      -- I have looked under the crashdummyy/mason-registry for tags, but the latest 5.4.x that they have is not available to dowload as 
      -- a release anymore.
      --
      -- Disabling roslyn until there is a stable version. Run `:MasonInstall roslyn@5.4.0-2.26175.10` to install the last working version.
      -- "roslyn", 
      "eslint_d",
    },
  },
}
