return {
	"williamboman/mason.nvim",
	lazy = false,
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "",
					package_pending = "",
					package_uninstalled = "",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"buf_ls",
				"bashls",
				"gopls",
				"kulala-fmt",
				"templ",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"stylua",
				"eslint",
				"prettier",
				"gopls",
				"kulala-fmt",
				"templ",
			},
		})
	end,
}
