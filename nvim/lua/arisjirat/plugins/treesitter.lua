return {
	"nvim-treesitter/nvim-treesitter",
	-- Pin to the legacy `master` branch. The new `main` branch (v1.0+) drops
	-- the `nvim-treesitter.configs` module that this setup() call uses.
	-- Migration to the new API is a separate task.
	branch = "master",

	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		vim.filetype.add({
			extension = {
				jsp = "html",
			},
		})
		require("nvim-treesitter.configs").setup({
			-- enable indentation
			indent = { enable = true },
			-- enable autotagging (w/ nvim-ts-autotag plugin)
			autotag = {
				enable = true,
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
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
		})
	end,
}
