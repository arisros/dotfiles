return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	config = function()
		local highlight = {
			"CursorColumn",
		}
		local hooks = require("ibl.hooks")
		-- create the highlight groups in the highlight setup hook, so they are reset
		-- every time the colorscheme changes
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "CursorColumn", { fg = "#2d2d2d" })
			-- vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
			-- vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
			-- vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
			-- vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
			-- vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
		end)
		require("ibl").setup({
			indent = { highlight = highlight, char = "┊" },
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = false,
			},
			scope = { enabled = true },
		})
		-- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		-- vim.g.indent_blankline_char = "│"
		-- vim.g.indent_blankline_filetype_exclude = { "help", "packer" }
		-- vim.g.indent_blankline_buftype_exclude = { "terminal" }
		-- vim.g.indent_blankline_show_trailing_blankline_indent = false
		-- vim.g.indent_blankline_show_first_indent_level = false
		-- vim.g.indent_blankline_use_treesitter = true
		-- vim.g.indent_blankline_show_current_context = true
	end,
	-- opts = {
	-- 	-- indent = { char = "┊" },
	-- 	indent = { char = "│" },
	-- },
}
