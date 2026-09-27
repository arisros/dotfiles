return {
	"searleser97/mermaid-nvim",
	ft = { "markdown" },
	-- Needs a mermaid-to-ASCII CLI on PATH: pipx install 'termaid[rich]'
	opts = {
		cmd = { "termaid", "--gap", "2" },
		enabled = true,
		preview_mode = "float",
		shorten_labels = false,
		inline_render_delay_ms = 300,
		on_error = "virtual_text",
		highlights = {
			diagram = "MermaidDiagram",
			legend = "MermaidLegend",
		},
	},
	config = function(_, opts)
		-- Upstream hashes with a NUL separator; nvim turns that into a Blob and sha256 raises
		-- E976, killing every render. Drop when mermaid-nvim fixes cache.hash.
		local cache = require("mermaid-nvim.cache")
		cache.hash = function(content, cmd)
			return vim.fn.sha256(table.concat(cmd, "\1") .. "\1" .. content)
		end

		require("mermaid-nvim").setup(opts)

		local function apply_mermaid_highlights()
			vim.api.nvim_set_hl(0, "MermaidDiagram", { fg = "#8a94a6", bg = "NONE" })
			vim.api.nvim_set_hl(0, "MermaidLegend", { fg = "#7a9ec2", bg = "NONE" })
		end

		apply_mermaid_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = apply_mermaid_highlights,
		})
	end,
}
