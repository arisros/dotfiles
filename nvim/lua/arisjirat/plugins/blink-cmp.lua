return {
	"saghen/blink.cmp",
	version = "*",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"L3MON4D3/LuaSnip",
		"fang2hou/blink-copilot",
	},
	opts = {
		keymap = {
			preset = "none",
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<Tab>"] = {
				function()
					local ok, suggestion = pcall(require, "copilot.suggestion")
					if ok and suggestion.is_visible() then
						suggestion.accept()
						return true
					end
				end,
				"select_next",
				"snippet_forward",
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
			kind_icons = {
				Copilot = "",
			},
		},
		sources = {
			default = { "copilot", "lsp", "path", "snippets", "buffer" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					async = true,
					score_offset = 100,
					opts = {
						max_completions = 3,
					},
				},
			},
		},
		completion = {
			accept = { auto_brackets = { enabled = true } },
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			menu = {
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},
		},
		snippets = { preset = "luasnip" },
	},
}
