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
		require("flutter-tools").setup({
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
		})
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
