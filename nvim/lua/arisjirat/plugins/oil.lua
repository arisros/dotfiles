return {
	"stevearc/oil.nvim",
	dependencies = { "echasnovski/mini.icons" },
	config = function()
		require("oil").setup({
			default_file_explorer = false,
			columns = { "icon" },
			view_options = {
				show_hidden = true,
			},
		})
		-- vim.keymap.set("n", "-", "<cmd>Oil<CR>")
		vim.keymap.set("n", "<leader>-", require("oil").toggle_float)
	end,
}
