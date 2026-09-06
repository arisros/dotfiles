return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local keymap = vim.keymap
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		local function lsp_references_dynamic_width()
			local fname_width = 30
			local ok, pane_width = pcall(function()
				return tonumber(vim.fn.system("tmux display -p '#{pane_width}'"))
			end)
			if ok and pane_width and pane_width > 0 then
				fname_width = math.floor(pane_width / 2)
			end
			require("telescope.builtin").lsp_references({ fname_width = fname_width })
		end

		-- Keymaps on LspAttach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", lsp_references_dynamic_width, opts)

				opts.desc = "Go to definition"
				keymap.set("n", "gD", vim.lsp.buf.definition, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>gr", vim.lsp.buf.rename, opts)
				keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, noremap = true, silent = true })

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- Diagnostic signs (Neovim 0.11+ API)
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- Default capabilities for all servers (mason-lspconfig v2 automatic_enable)
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- Server-specific overrides

		-- rust-analyzer comes from rustup, not mason, so mason-lspconfig's
		-- automatic_enable never picks it up.
		if vim.fn.executable("rust-analyzer") == 1 then
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						-- allTargets/allFeatures are already appended by rust-analyzer;
						-- repeating them in extraArgs makes cargo reject the command.
						check = { command = "clippy" },
						cargo = { allFeatures = true, buildScripts = { enable = true } },
						procMacro = { enable = true },
					},
				},
			})
			vim.lsp.enable("rust_analyzer")
		end

		vim.lsp.config("omnisharp", {
			cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/omnisharp"), "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
			capabilities = capabilities,
			enable_roslyn_analyzers = true,
			organize_imports_on_format = true,
			enable_import_completion = true,
		})

		vim.lsp.config("intelephense", {
			capabilities = capabilities,
			filetypes = { "php" },
			root_markers = { "composer.json", ".git" },
		})

		vim.lsp.config("arduino_language_server", {
			cmd = {
				vim.fn.expand("~/.local/share/nvim/mason/bin/arduino-language-server"),
				"-cli", vim.fn.expand("~/.local/share/mise/installs/arduino/1.2.0/arduino-cli"),
				"-cli-config", vim.fn.expand("~/Library/Arduino15/arduino-cli.yaml"),
				"-fqbn", "arduino:avr:uno",
				"-clangd", "/usr/bin/clang",
			},
			capabilities = capabilities,
			filetypes = { "arduino", "cpp", "c" },
			root_markers = { "*.ino", ".git", "arduino.json" },
		})
	end,
}
