return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
	opts = {
		anti_conceal = { enabled = false },
		file_types = { "markdown", "Avante", "copilot-chat", "opencode_output" },

		heading = {
			-- No background tinting on headings
			backgrounds = { "NONE", "NONE", "NONE", "NONE", "NONE", "NONE" },
			foregrounds = {
				"RenderMarkdownH1",
				"RenderMarkdownH2",
				"RenderMarkdownH3",
				"RenderMarkdownH4",
				"RenderMarkdownH5",
				"RenderMarkdownH6",
			},
			icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
			signs = { "" },
		},
		bullet = {
			icons = { "•", "◦", "▸", "▹" },
		},
		checkbox = {
			unchecked = { icon = "☐ " },
			checked = { icon = "☑ " },
		},
		code = {
			border = "thin",
			-- Minimal code block background so it doesn't pop too much
			highlight = "RenderMarkdownCode",
		},
		sign = { enabled = false },
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)

		local function apply_md_highlights()
			-- Headings: muted, no background
			vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#d0d0d0", bold = true, bg = "NONE" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = "#b0b8c8", bold = true, bg = "NONE" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = "#909aaa", bold = false, bg = "NONE" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = "#787e8a", bold = false, bg = "NONE" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = "#606470", bg = "NONE" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = "#505458", bg = "NONE" })

			-- Heading backgrounds: fully cleared
			for i = 1, 6 do
				vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { bg = "NONE", fg = "NONE" })
			end

			-- Code blocks: very subtle dark tint, no vivid border
			vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#1e1e1e" })
			vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#b0b8c8", bg = "#252525" })

			-- Bullets, quotes, links: understated
			vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#606470" })
			vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = "#606470", italic = true })
			vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#7a9ec2", underline = true })

			-- Table: subtle borders
			vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = "#505458", bold = true })
			vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = "#505458" })
		end

		apply_md_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = apply_md_highlights,
		})
	end,
}
