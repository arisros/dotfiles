return {
	"nvim-treesitter/nvim-treesitter",

	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		"windwp/nvim-ts-autotag",
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
				"cpp",
				"dart",
				"python",
				"java",
				"xml",
				"go",
				"templ",
				"http",
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			autotag = { enable = true },
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function start" },
					},
					goto_previous_start = {
						["[f"] = { query = "@function.outer", desc = "Previous function start" },
					},
				},
			},
		})

		require("treesitter-context").setup({
			enable = true,
			max_lines = 3,
			trim_scope = "outer",
			mode = "cursor",
			separator = "─",
			zindex = 20,
		})

		vim.keymap.set("n", "[c", function()
			require("treesitter-context").go_to_context()
		end, { desc = "Jump to function context" })
	end,
}
