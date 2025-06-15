return {
	"olimorris/codecompanion.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		adapters = {
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					env = {
						api_key = os.getenv("OPENAI_API_KEY"), -- Use your env variable here
					},
					model = "gpt-4", -- or "gpt-3.5-turbo"
				})
			end,
		},
	},
	cmd = { "CodeCompanion" },
	keys = {
		{ "<leader>cc", "<cmd>CodeCompanion<CR>", desc = "Open Code Companion" },
		{ "<leader>ce", ":'<,'>CodeCompanion explain<CR>", mode = "v", desc = "Explain selected code" },
	},
}
