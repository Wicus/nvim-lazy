return {
	"folke/which-key.nvim",
	opts = {
		spec = {
			-- {
			-- 	mode = { "n", "v" },
			-- 	{ "<leader><tab>", group = "tabs" },
			-- 	{ "<leader>c", group = "code" },
			-- 	{ "<leader>d", group = "debug" },
			-- 	{ "<leader>dp", group = "profiler" },
			-- 	{ "<leader>f", group = "file/find" },
			-- 	{ "<leader>g", group = "git" },
			-- 	{ "<leader>gh", group = "hunks" },
			-- 	{ "<leader>q", group = "quit/session" },
			-- 	{ "<leader>s", group = "search" },
			-- 	{ "<leader>u", group = "ui/toggle" },
			-- 	{ "<leader>x", group = "diagnostics/quickfix" },
			-- 	{ "[", group = "prev" },
			-- 	{ "]", group = "next" },
			-- 	{ "g", group = "goto" },
			-- 	{ "gr", group = "lsp" },
			-- 	{ "gs", group = "surround" },
			-- 	{ "z", group = "fold" },
			-- 	{
			-- 		"<leader>b",
			-- 		group = "buffer",
			-- 		expand = function() return require("which-key.extras").expand.buf() end,
			-- 	},
			-- 	{
			-- 		"<leader>w",
			-- 		group = "windows",
			-- 		proxy = "<c-w>",
			-- 		expand = function() return require("which-key.extras").expand.win() end,
			-- 	},
			-- 	-- better descriptions
			-- 	{ "gx", desc = "Open with system app" },
			-- },
		},
	},
}
