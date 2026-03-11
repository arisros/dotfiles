return {
	"sudo-tee/opencode.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MeanderingProgrammer/render-markdown.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local opencode = require("opencode")

		opencode.setup({
			api = {
				base_url = os.getenv("OPENCODE_API_URL") or "https://api.ohmyopencode.com",
				api_key = os.getenv("OPENCODE_API_KEY"),
			},
			model = {
				default = "claude-sonnet-4",
				temperature = 0.7,
				max_tokens = 8192,
			},
			chat = {
				layout = "vertical",
				width = 0.5,
				show_system_prompt = false,
				auto_scroll = true,
				history = true,
				history_size = 50,
			},
			code_actions = {
				auto_format = true,
				auto_save = false,
				show_diff = true,
			},
			lsp = {
				include_diagnostics = true,
				include_hover = true,
				max_diagnostics = 10,
			},
			telescope = {
				enabled = true,
				theme = "ivy",
				previewer = true,
			},
			context = {
				auto_include_related = true,
				max_lines_per_file = 500,
				include_git_diff = true,
			},
			keymaps = {
				enabled = true,
			},
		})

		local keymap = vim.keymap
		local opts = { noremap = true, silent = true }

		keymap.set(
			"n",
			"<leader>oc",
			":OpenCodeChat<CR>",
			vim.tbl_extend("force", opts, { desc = "Open OpenCode chat" })
		)
		keymap.set(
			"n",
			"<leader>oo",
			":OpenCodeToggle<CR>",
			vim.tbl_extend("force", opts, { desc = "Toggle OpenCode window" })
		)
		keymap.set(
			"v",
			"<leader>oe",
			":'<,'>OpenCodeExplain<CR>",
			vim.tbl_extend("force", opts, { desc = "Explain selected code" })
		)
		keymap.set(
			"v",
			"<leader>or",
			":'<,'>OpenCodeRefactor<CR>",
			vim.tbl_extend("force", opts, { desc = "Refactor selected code" })
		)
		keymap.set(
			"v",
			"<leader>of",
			":'<,'>OpenCodeFix<CR>",
			vim.tbl_extend("force", opts, { desc = "Fix selected code" })
		)
		keymap.set(
			"n",
			"<leader>od",
			":OpenCodeDoc<CR>",
			vim.tbl_extend("force", opts, { desc = "Generate documentation" })
		)
		keymap.set("n", "<leader>ot", ":OpenCodeTest<CR>", vim.tbl_extend("force", opts, { desc = "Generate tests" }))
		keymap.set(
			"n",
			"<leader>op",
			":OpenCodeOptimize<CR>",
			vim.tbl_extend("force", opts, { desc = "Optimize code" })
		)
		keymap.set(
			"n",
			"<leader>oa",
			":OpenCodeAddContext<CR>",
			vim.tbl_extend("force", opts, { desc = "Add file to context" })
		)
		keymap.set(
			"n",
			"<leader>ox",
			":OpenCodeClearContext<CR>",
			vim.tbl_extend("force", opts, { desc = "Clear context" })
		)
		keymap.set(
			"n",
			"<leader>ol",
			":OpenCodeListContext<CR>",
			vim.tbl_extend("force", opts, { desc = "List context files" })
		)
		keymap.set(
			"n",
			"<leader>oD",
			":OpenCodeFixDiagnostics<CR>",
			vim.tbl_extend("force", opts, { desc = "Fix all diagnostics in file" })
		)
		keymap.set(
			"n",
			"<leader>oh",
			":OpenCodeFixLine<CR>",
			vim.tbl_extend("force", opts, { desc = "Fix diagnostics on current line" })
		)
		keymap.set(
			"n",
			"<leader>oh",
			":Telescope opencode_history<CR>",
			vim.tbl_extend("force", opts, { desc = "OpenCode chat history" })
		)
		keymap.set(
			"n",
			"<leader>os",
			":Telescope opencode_sessions<CR>",
			vim.tbl_extend("force", opts, { desc = "OpenCode sessions" })
		)
		keymap.set(
			"n",
			"<leader>oq",
			":OpenCodeQuickPrompt<CR>",
			vim.tbl_extend("force", opts, { desc = "Quick prompt" })
		)
		keymap.set(
			"v",
			"<leader>oq",
			":'<,'>OpenCodeQuickPrompt<CR>",
			vim.tbl_extend("force", opts, { desc = "Quick prompt with selection" })
		)

		local telescope_loaded, telescope = pcall(require, "telescope")
		if telescope_loaded then
			pcall(telescope.load_extension, "opencode")

			keymap.set(
				"n",
				"<leader>fc",
				":Telescope opencode_commands<CR>",
				vim.tbl_extend("force", opts, { desc = "OpenCode commands" })
			)
			keymap.set(
				"n",
				"<leader>fp",
				":Telescope opencode_prompts<CR>",
				vim.tbl_extend("force", opts, { desc = "OpenCode prompts" })
			)
		end

		local opencode_group = vim.api.nvim_create_augroup("OpenCodeAuto", { clear = true })

		vim.api.nvim_create_autocmd("User", {
			pattern = "OpenCodeGenerateComplete",
			group = opencode_group,
			callback = function()
				local config = opencode.get_config and opencode.get_config() or {}
				if config.code_actions and config.code_actions.auto_format then
					local conform_loaded, conform = pcall(require, "conform")
					if conform_loaded then
						conform.format({
							lsp_fallback = true,
							async = false,
							timeout_ms = 1000,
						})
					end
				end
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "OpenCodeApplyComplete",
			group = opencode_group,
			callback = function()
				local config = opencode.get_config and opencode.get_config() or {}
				if config.code_actions and config.code_actions.auto_save then
					vim.cmd("silent! write")
				end
			end,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = opencode_group,
			callback = function(ev)
				local bufnr = ev.buf
				local lsp_opts = { buffer = bufnr, silent = true }

				lsp_opts.desc = "Fix with OpenCode"
				keymap.set("n", "<leader>oF", function()
					local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })
					if #diagnostics > 0 then
						vim.cmd("OpenCodeFixLine")
					else
						vim.notify("No diagnostics on current line", vim.log.levels.INFO)
					end
				end, lsp_opts)
			end,
		})

		vim.api.nvim_create_user_command("OpenCodeCommitMsg", function()
			local git_diff = vim.fn.system("git diff --staged")
			if git_diff == "" then
				vim.notify("No staged changes", vim.log.levels.WARN)
				return
			end

			if opencode.generate_commit_message then
				opencode.generate_commit_message(git_diff)
			else
				vim.notify("OpenCode: generate_commit_message not available", vim.log.levels.WARN)
			end
		end, { desc = "Generate commit message with OpenCode" })

		vim.api.nvim_create_user_command("OpenCodeExplainError", function()
			local line = vim.fn.line(".")
			local diagnostics = vim.diagnostic.get(0, { lnum = line - 1 })

			if #diagnostics == 0 then
				vim.notify("No diagnostics on current line", vim.log.levels.INFO)
				return
			end

			local diagnostic = diagnostics[1]
			if opencode.explain_diagnostic then
				opencode.explain_diagnostic(diagnostic)
			else
				vim.notify("OpenCode: explain_diagnostic not available", vim.log.levels.WARN)
			end
		end, { desc = "Explain LSP error with OpenCode" })

		vim.api.nvim_create_user_command("OpenCodeSmartRefactor", function(opts)
			local bufnr = vim.api.nvim_get_current_buf()

			vim.lsp.buf_request(bufnr, "textDocument/hover", vim.lsp.util.make_position_params(), function(err, result)
				if not err and result then
					if opencode.refactor_with_context then
						opencode.refactor_with_context(result, opts.args)
					else
						vim.notify("OpenCode: refactor_with_context not available", vim.log.levels.WARN)
					end
				else
					if opencode.refactor then
						opencode.refactor(opts.args)
					else
						vim.notify("OpenCode: refactor not available", vim.log.levels.WARN)
					end
				end
			end)
		end, { nargs = "?", desc = "Smart refactor with LSP context" })

		_G.opencode_status = function()
			if opencode.get_status then
				local status = opencode.get_status()
				if status.active then
					return "🤖 " .. status.message
				end
			end
			return ""
		end
	end,
}
