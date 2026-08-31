return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "VeryLazy",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		enable = true,
		max_lines = 3, -- How many lines the sticky context can occupy
		trim_scope = "outer",
		min_window_height = 0,
		mode = "cursor", -- Show context based on cursor position
		separator = "─", -- Nice visual separator
		zindex = 20,
	},
	keys = {
		{
			"<leader>tc",
			function()
				require("treesitter-context").toggle()
			end,
			desc = "Toggle Treesitter Context",
		},
	},
}
