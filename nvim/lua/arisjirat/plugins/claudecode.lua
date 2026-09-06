return {
	"coder/claudecode.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		auto_start = true,
		track_selection = true,
		terminal = {
			provider = "native",
			split_side = "right",
			split_width_percentage = 0.35,
		},
	},
	keys = {
		{ "<leader>a", nil, desc = "Claude Code" },
		{ "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<CR>", desc = "Resume session" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<CR>", desc = "Continue last session" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Select model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<CR>",
			desc = "Add file from tree",
			ft = { "NvimTree", "neo-tree", "oil" },
		},
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Deny diff" },
		{ "<leader>ax", "<cmd>ClaudeCodeStatus<CR>", desc = "Connection status" },
	},
}
