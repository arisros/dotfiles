return {
	"nvim-treesitter/nvim-treesitter",

	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",

	dependencies = {
		"windwp/nvim-ts-autotag",

		-- NEW: context + textobjects
		"nvim-treesitter/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},

	config = function()
		vim.filetype.add({
			extension = {
				jsp = "html",
			},
		})

		require("nvim-treesitter.configs").setup({
			indent = { enable = true },

			autotag = {
				enable = true,
			},

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},

			ensure_installed = {
				"astro",
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"gitignore",
				"vimdoc",
				"c",
				"dart",
				"python",
				"java",
				"xml",
				"go",
				"templ",
				"http",
			},

			-- 🚀 NEW SECTION: function navigation
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,

					goto_next_start = {
						["]f"] = "@function.outer",
					},

					goto_previous_start = {
						["[f"] = "@function.outer",
					},
				},
			},
		})

		-- STICKY FUNCTION HEADER CONFIG
		require("treesitter-context").setup({
			enable = true,
			max_lines = 3,
			trim_scope = "outer",
			mode = "cursor",
			separator = "─",
			zindex = 20,
		})

		-- KEYMAP: jump to current function header
		vim.keymap.set("n", "[c", function()
			require("treesitter-context").go_to_context()
		end, { desc = "Jump to function context" })
	end,
}
