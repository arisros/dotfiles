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
				"astro",
				"lua_ls",
				"ts_ls",
				"buf_ls",
				"bashls",
				"clangd",
				"gopls",
				"templ",
				"jdtls",
				"lemminx",
				"intelephense",
				"pyright",
				"omnisharp",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"astro-language-server",
				"omnisharp",
				"stylua",
				"eslint",
				"prettier",
				"gopls",
				"templ",
				"prettierd",
				"arduino_language_server",
				"jdtls",
				"clangd",
				"clang-format",
				"codelldb",
				"intelephense",
				"pyright",
			},
		})
	end,
}
