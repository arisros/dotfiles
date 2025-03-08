return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		require("dapui").setup()
		require("dap-go").setup({})
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
		vim.keymap.set("n", "<Leader>bc", dap.continue, {})
		vim.keymap.set("n", "<Leader>br", ":lua require('dapui').open({reset = true})<CR>", {})

		-- 🔹 Customize Breakpoint Symbol
		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "⏺", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
		)
	end,
}
