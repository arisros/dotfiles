return {
	"nvimtools/none-ls.nvim", -- migrated from jose-elias-alvarez/null-ls.nvim
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local mason = require("mason")

		mason.setup()

		null_ls.setup({
			sources = {
				-- Java formatter
				null_ls.builtins.formatting.google_java_format,

				-- JSP treated as HTML (using Prettier)
				null_ls.builtins.formatting.prettier.with({
					filetypes = { "html", "css", "javascript", "jsp" },
				}),
			},
		})
	end,
}
