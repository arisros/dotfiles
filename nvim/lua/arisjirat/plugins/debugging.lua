return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
		"nvim-telescope/telescope-dap.nvim",
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		require("dapui").setup()
		require("dap-go").setup({})

		require("telescope").load_extension("dap")
		-- dap.listeners.before.event_terminated["dapui_keep_open"] = function()
		-- 	dapui.open()
		-- end
		--
		-- dap.listeners.before.event_exited["dapui_keep_open"] = function()
		-- 	dapui.open()
		-- end
		dap.listeners.before.event_exited["show_dap_error"] = function(session, body)
			if body and body.exitCode and body.exitCode ~= 0 then
				vim.notify("DAP exited with error code: " .. body.exitCode, vim.log.levels.ERROR)
			else
				vim.notify("DAP exited normally.", vim.log.levels.INFO)
			end
		end
		-- 🔹 DAP UI Auto Open/Close
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- 🔹 Keybindings
		vim.keymap.set("n", "<Leader>bb", dap.toggle_breakpoint, {})
		-- add variable to watch

		vim.keymap.set("n", "<Leader>bc", dap.continue, {})
		-- continue to next line
		vim.keymap.set("n", "<Leader>bn", dap.step_over, {})
		vim.keymap.set("n", "<Leader>bs", dap.step_into, {})
		vim.keymap.set("n", "<Leader>bo", dap.step_out, {})

		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function()
				if vim.bo.filetype == "dap-repl" then
					vim.keymap.set("n", "n", function()
						require("dap").step_over()
					end, { buffer = true })
				end
			end,
		})

		-- restart the debug session
		vim.keymap.set("n", "<Leader>br", dap.restart, {})

		-- vim.keymap.set("n", "<Leader>br", ":lua require('dapui').open({reset = true})<CR>", {})

		-- 🔹 Customize Breakpoint Symbol
		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "⏺", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
	end,
}
