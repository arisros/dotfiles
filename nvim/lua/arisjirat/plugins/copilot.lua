return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			-- Disable built-in suggestion/panel — handled by blink-copilot source
			suggestion = { enabled = false },
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
