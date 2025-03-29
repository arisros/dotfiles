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
				-- templfmt = {
				-- 	command = "templ",
				-- 	args = { "fmt", "--tab-width=4" },
				-- 	stdin = true,
				-- },
				templfmt = {
					command = "templ",
					args = { "fmt" },
					stdin = true,
				},
				indentfix = {
					command = "sed",
					args = { "-i", "s/  /    /g" },
					stdin = false,
				},
				-- templ = {
				-- 	prepend_args = { "--tab-width", "4" },
				-- 	-- command = "templ",
				-- 	-- args = { "format", "$FILENAME" },
				-- 	-- stdin = false,
				-- },
			},
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				javascriptreact = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettierd" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				dart = { "dart_format" },
				bash = { "beautysh" },
				sh = { "beautysh" },
				go = { "gofmt" },
				-- templ = { "templfmt" },
				-- templ = { "templfmt", "indentfix" },
				-- templ = { "templ" },
				templ = { "gofmt" },
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
