return {
	"mbbill/undotree",
	keys = {
		{ "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undotree" },
	},
	init = function() vim.g.undotree_SplitWidth = 79 end,
}
