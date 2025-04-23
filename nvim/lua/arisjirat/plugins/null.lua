--
-- local null_ls = require("null-ls")
--
-- null_ls.setup({
--   sources = {
--     -- Java
--     null_ls.builtins.formatting.google_java_format,
--
--     -- JSP (treated as HTML)
--     null_ls.builtins.formatting.prettier.with({
--       filetypes = { "html", "css", "javascript", "jsp" },
--     }),
--   },
-- })

return {
	"jose-elias-alvarez/null-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"mason.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")

		mason.setup()
		mason_lspconfig.setup()

		null_ls.setup({
			sources = {
				-- Java
				null_ls.builtins.formatting.google_java_format,

				-- JSP (treated as HTML)
				null_ls.builtins.formatting.prettier.with({
					filetypes = { "html", "css", "javascript", "jsp" },
				}),
			},
		})
	end,
}
