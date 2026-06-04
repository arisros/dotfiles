return {
	-- Main AI plugin
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- core dep
			"MeanderingProgrammer/render-markdown.nvim", -- markdown renderer
			"OXY2DEV/markview.nvim", -- optional alt renderer
			"echasnovski/mini.diff", -- inline diff
			"HakonHarnes/img-clip.nvim", -- paste image to chat
			"hrsh7th/nvim-cmp", -- completion
			-- "ravitemer/mcphub.nvim", -- enable after: npm install -g mcp-hub@latest
		},
		config = function()
			------------------------------------------------------------
			-- 🔧 MAIN CONFIG
			------------------------------------------------------------
			require("codecompanion").setup({
				adapters = {
					-- Example: using OpenAI
					openai = {
						model = "gpt-4o-mini",
						api_key = os.getenv("OPENAI_API_KEY"),
					},
				},

				chat = {
					-- auto open chat buffer in vertical split
					layout = "vertical",
					show_system_prompt = true,
					history = true,
				},

				tools = {
					insert_edit_into_file = true,
					grep_search = true,
				},

				-- extensions = {
				-- 	mcphub = {
				-- 		callback = "mcphub.extensions.codecompanion",
				-- 		opts = { make_vars = true, make_slash_commands = true, show_result_in_chat = true },
				-- 	},
				-- },
			})

			------------------------------------------------------------
			-- 🪄 MINI.DIFF (inline diff)
			------------------------------------------------------------
			local diff = require("mini.diff")
			diff.setup({
				source = diff.gen_source.none(), -- disabled auto
			})

		end,
	},

	------------------------------------------------------------
	-- 📜 RENDER MARKDOWN (disabled — markview is used instead)
	------------------------------------------------------------
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},

	------------------------------------------------------------
	-- 🪶 MARKVIEW (alternative renderer)
	------------------------------------------------------------
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		opts = {
			preview = {
				filetypes = { "markdown", "codecompanion" },
				ignore_buftypes = {},
			},
		},
	},

	------------------------------------------------------------
	-- 🖼️ IMG-CLIP (paste from clipboard)
	------------------------------------------------------------
	{
		"HakonHarnes/img-clip.nvim",
		opts = {
			filetypes = {
				codecompanion = {
					prompt_for_file_name = false,
					template = "[Image]($FILE_PATH)",
					use_absolute_path = true,
				},
			},
		},
	},

	------------------------------------------------------------
	-- 🤖 COMPLETION
	------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			opts.sources = vim.tbl_deep_extend("force", opts.sources, {
				{ name = "codecompanion", group_index = 1 },
			})
			return opts
		end,
	},
}
