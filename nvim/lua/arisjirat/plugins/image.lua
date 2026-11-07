return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = true,
			doc = {
				inline = true,
				float = true,
				max_width = 70,
				max_height = 20,
			},
		},
	},
	keys = {
		{
			"<leader>mi",
			function()
				Snacks.image.hover()
			end,
			ft = { "markdown" },
			desc = "Preview image under cursor",
		},
	},
}
