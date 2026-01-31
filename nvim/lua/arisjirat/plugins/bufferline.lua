return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	keys = {
		{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
		{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
	},

	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				numbers = "ordinal",

				indicator = { style = "none" },

				modified_icon = "●",
				buffer_close_icon = "",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",

				show_buffer_icons = false,
				show_buffer_close_icons = false,
				show_close_icon = false,
				show_tab_indicators = false,

				diagnostics = false,
				separator_style = { "", "" },
				always_show_bufferline = true,
			},

			highlights = {
				fill = {
					bg = "NONE",
				},
				background = {
					fg = "#ffffff",
					bg = "NONE",
				},
				numbers = {
					fg = "#ffffff",
					bg = "NONE",
				},

				buffer_selected = {
					bg = "#cc6667",
					bold = true,
					italic = false,
				},
				numbers_selected = {
					bg = "#cc6667",
					bold = true,
				},

				-- UNSAVED: dot only, no background
				modified = {
					fg = "#e5c07b",
					bg = "NONE",
				},
				modified_selected = {
					fg = "#e5c07b",
					bg = "NONE",
				},

				-- clean separators
				separator = {
					fg = "NONE",
					bg = "NONE",
				},
				separator_selected = {
					fg = "NONE",
					bg = "NONE",
				},
			},
		})

		-- Keymaps to go to buffer 1-9
		for i = 1, 9 do
			vim.keymap.set("n", "<Leader>" .. i, function()
				require("bufferline").go_to_buffer(i, true)
			end, { silent = true, desc = "Go to buffer " .. i })
		end
	end,
}
