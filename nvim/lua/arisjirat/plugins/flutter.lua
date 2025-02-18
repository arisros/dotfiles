return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for vim.ui.select
		{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	},
	-- config = true,
	config = function()
		local ft = require("flutter-tools").setup({
			decorations = {
				statusline = {
					-- set to true to be able use the 'flutter_tools_decorations.app_version' in your statusline
					-- this will show the current version of the flutter app from the pubspec.yaml file
					app_version = true,
					-- set to true to be able use the 'flutter_tools_decorations.device' in your statusline
					-- this will show the currently running device if an application was started with a specific
					-- device
					device = true,
					-- set to true to be able use the 'flutter_tools_decorations.project_config' in your statusline
					-- this will show the currently selected project configuration
					project_config = true,
				},
			},

			-- flutter_path = "~/fvm/default/bin/dart",
			-- lsp = {
			--   cmd = { "~/fvm/default/bin/dart", "language-server", "--protocol=lsp" },
			-- },
			-- flutter_lookup_cmd = "dirname $(which flutter)",
			-- fvm = false,
			-- fvm = {
			--   sdk = "~/fvm/versions/3.24.0",
			-- },
			debugger = {
				enabled = true,
				register_configurations = function(_)
					require("dap").configurations.dart = {}
					require("dap.ext.vscode").load_launchjs()
				end,
			},
			dev_log = {
				notify_errors = true,
			},
			outline = {
				auto_open = true,
			},

			dev_tools = {
				autostart = true,
				auto_open_browser = true,
			},
		})

		local map = vim.keymap.set

		map("n", "<leader>rrd", "<cmd>FlutterDevices<CR>", { desc = "Run on device" })
		map("n", "<leader>rrh", "<cmd>FlutterHotReload<CR>", { desc = "Hot reload" })
		map("n", "<leader>rrs", "<cmd>FlutterHotRestart<CR>", { desc = "Hot restart" })
		map("n", "<leader>rrQ", "<cmd>FlutterQuit<CR>", { desc = "Quit flutter app" })
		map("n", "<leader>rrt", "<cmd>FlutterTest<CR>", { desc = "Run tests" })
		-- log clear
		map("n", "<leader>rrc", "<cmd>FlutterLogClear<CR>", { desc = "Clear log" })
		-- toggle log
		map("n", "<leader>rrg", "<cmd>FlutterLogToggle<CR>", { desc = "Toggle log" })
		-- open dev tools
		map("n", "<leader>rrb", "<cmd>FlutterDevTools<CR>", { desc = "Open dev tools" })
		-- toggle outline
		map("n", "<leader>rro", "<cmd>FlutterOutlineToggle<CR>", { desc = "Toggle outline" })
	end,

	-- config = function ()
	--   require("flutter-tools").setup({
	--     -- flutter_path = "~/fvm/default/bin/dart",
	--     -- lsp = {
	--     --   cmd = { "~/fvm/default/bin/dart", "language-server", "--protocol=lsp" },
	--     -- },
	--     -- flutter_lookup_cmd = "dirname $(which flutter)",
	--     -- fvm = false,
	--     -- fvm = {
	--     --   sdk = "~/fvm/versions/3.24.0",
	--     -- },
	--   })
	-- end,
}
