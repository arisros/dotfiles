return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters = {
				kulala = {
					command = "kulala-fmt",
					args = { "format", "$FILENAME" },
					stdin = false,
				},
				indentfix = {
					command = "sed",
					args = { "-i", "s/  /    /g" },
					stdin = false,
				},
				["blade-formatter"] = {
					command = "blade-formatter",
					args = { "--stdin" },
					stdin = true,
				},
				csharpier = {
					-- Pakai global tool yang sudah terbukti ada
					command = vim.fn.expand("~/.dotnet/tools/csharpier"),
					args = { "format" },
					stdin = true,
				},
				prettier_yaml = {
					command = "prettier",
					args = {
						"--no-semi",
						"--arrow-parens=avoid",
						"--single-quote=true",
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
				},
			},
			formatters_by_ft = {
				cs = { "csharpier" },
				php = { "pint", "php_cs_fixer" },
				blade = { "blade-formatter" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				javascriptreact = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettierd" },
				yaml = { "prettier_yaml" },
				markdown = { "prettier" },
				lua = { "stylua" },
				dart = { "dart_format" },
				bash = { "beautysh" },
				sh = { "beautysh" },
				go = { "gofmt" },
				http = { "kulala" },
			},
			format_on_save = {
				enabled = true,
				async = false,
				timeout = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout = 1000,
			})
		end)
	end,
}
