return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = false,
				debounce = 75,
				keymap = {
					accept = "<C-l>",
					accept_word = "<M-w>",
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = { enabled = false },
			filetypes = {
				["*"] = true,
				markdown = false,
				text = false,
				gitcommit = false,
			},
			copilot_node_command = "node",
			server_opts_overrides = {
				settings = {
					advanced = {
						inlineSuggestCount = 3,
					},
				},
			},
		})
	end,
}
