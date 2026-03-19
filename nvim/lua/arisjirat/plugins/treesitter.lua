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

		local parsers = {
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
		}

		-- Install parsers (new API: no more configs.setup)
		require("nvim-treesitter").install(parsers)

		-- Enable treesitter highlighting & indentation for all filetypes with parsers
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				local ok = pcall(vim.treesitter.start)
				if ok then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- Autotag (new standalone setup)
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
		})

		-- Textobjects: function navigation
		require("nvim-treesitter-textobjects").setup({
			move = {
				set_jumps = true,
			},
		})

		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })

		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })

		-- Sticky function header (treesitter-context)
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
