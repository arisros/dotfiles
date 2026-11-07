local ensure_installed = {
	"astro",
	"bash",
	"c",
	"cpp",
	"css",
	"dart",
	"gitignore",
	"go",
	"html",
	"http",
	"java",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"rust",
	"templ",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- master is frozen at Nvim 0.11: its query directives still read match[id] as a
		-- single node, which 0.12 turned into a list, breaking every markdown parse.
		branch = "main",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			vim.filetype.add({
				extension = {
					jsp = "html",
				},
			})

			local ts = require("nvim-treesitter")
			ts.install(ensure_installed)

			local available = {}
			for _, lang in ipairs(ts.get_available()) do
				available[lang] = true
			end

			local function start(buf, lang)
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				if not pcall(vim.treesitter.start, buf, lang) then
					return
				end
				if vim.treesitter.query.get(lang, "indents") then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ArisjiratTreesitter", { clear = true }),
				callback = function(event)
					local lang = vim.treesitter.language.get_lang(event.match)
					if not lang then
						return
					end
					if vim.treesitter.language.add(lang) then
						start(event.buf, lang)
					elseif available[lang] then
						ts.install({ lang }):await(vim.schedule_wrap(function(err)
							if not err then
								start(event.buf, lang)
							end
						end))
					end
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				move = { set_jumps = true },
			})

			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function start" })
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
}
