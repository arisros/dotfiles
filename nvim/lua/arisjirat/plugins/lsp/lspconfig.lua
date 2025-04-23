return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- "hrsh7th/cmp-nvim-lsp",
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-cmdline",
				"L3MON4D3/LuaSnip",
			},
		},
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local mason_lspconfig = require("mason-lspconfig")
		local lspconfig = require("lspconfig")
		local keymap = vim.keymap
		mason_lspconfig.setup_handlers({
			function(server)
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("UserLspConfig", {}),
					callback = function(ev)
						-- Buffer local mappings.
						-- See `:help vim.lsp.*` for documentation on any of the below functions
						local opts = { buffer = ev.buf, silent = true }

						-- set keybinds
						opts.desc = "Show LSP references"
						keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

						opts.desc = "Go to declaration"
						keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

						opts.desc = "Show LSP definitions"
						keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

						opts.desc = "Show LSP implementations"
						keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

						opts.desc = "Show LSP type definitions"
						keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

						opts.desc = "See available code actions"
						keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

						opts.desc = "Smart rename"
						keymap.set("n", "<leader>gr", vim.lsp.buf.rename, opts) -- smart rename
						vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true })

						opts.desc = "Show buffer diagnostics"
						keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics for file

						opts.desc = "Show line diagnostics"
						keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

						opts.desc = "Go to previous diagnostic"
						keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

						opts.desc = "Go to next diagnostic"
						keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

						opts.desc = "Show documentation for what is under cursor"
						keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

						opts.desc = "Restart LSP"
						keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
					end,
				})

				-- Change the Diagnostic symbols in the sign column (gutter)
				-- (not in youtube nvim video)
				local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
				end

				--if lspconfig[server] == nil then
				--  return
				-- end
				local cmp_nvim_lsp = require("cmp_nvim_lsp")
				cmp_nvim_lsp.default_capabilities()
				local capabilities = cmp_nvim_lsp.default_capabilities()

				if server == "arduino_language_server" then
					lspconfig.arduino_language_server.setup({
						cmd = {
							"/Users/justtest/.local/share/nvim/mason/bin/arduino-language-server",
							"-cli",
							"/Users/justtest/.local/share/mise/installs/arduino/1.2.0/arduino-cli",
							"-cli-config",
							"/Users/justtest/Library/Arduino15/arduino-cli.yaml",
							"-fqbn",
							"arduino:avr:uno",
							"-clangd",
							"/usr/bin/clang",
						},
						capabilities,
						filetypes = { "arduino", "cpp", "c" }, -- Arduino code is usually .ino, but .cpp is used internally
						root_dir = lspconfig.util.root_pattern("*.ino", ".git", "arduino.json"),
					})
				else
					lspconfig[server].setup({
						capabilities,
					})
				end

				-- if vim.lsp.protocol.make_client_capabilities then
				-- 	capabilities = vim.lsp.protocol.make_client_capabilities()
				-- end
				-- if server == "jdtls" then
				-- 	if not vim.fn.executable("jdtls") then
				-- 		vim.notify("jdtls is not installed or not in PATH", vim.log.levels.ERROR)
				-- 		return
				-- 	end
				-- 	lspconfig.jdtls.setup({
				-- 		root_dir = lspconfig.util.root_pattern("pom.xml", ".git"),
				-- 		cmd = { "jdtls" }, -- Ensure jdtls command is correct, or provide full path if needed
				-- 		capabilities = capabilities,
				-- 	})
				-- else
				-- 	lspconfig[server].setup({
				-- 		capabilities,
				-- 	})
				-- end
			end,
		})
	end,
}
