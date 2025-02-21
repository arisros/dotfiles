return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local custom_theme = {
			normal = {
				a = { fg = "#ffffff", bg = "#ff007c", gui = "bold" },
				b = { fg = "#ffffff", bg = "#5f00af" },
				c = { fg = "#d0d0d0", bg = "#303030" },
			},
			insert = {
				a = { fg = "#000000", bg = "#00ff00", gui = "bold" },
				b = { fg = "#ffffff", bg = "#005f5f" },
				c = { fg = "#ffffff", bg = "#303030" },
			},
			visual = {
				a = { fg = "#000000", bg = "#ffaf00", gui = "bold" },
				b = { fg = "#ffffff", bg = "#875f00" },
				c = { fg = "#ffffff", bg = "#303030" },
			},
			replace = {
				a = { fg = "#000000", bg = "#ff0000", gui = "bold" },
				b = { fg = "#ffffff", bg = "#870000" },
				c = { fg = "#ffffff", bg = "#303030" },
			},
			command = {
				a = { fg = "#ffffff", bg = "#5f00ff", gui = "bold" },
				b = { fg = "#ffffff", bg = "#3a3a3a" },
				c = { fg = "#ffffff", bg = "#303030" },
			},
			inactive = {
				a = { fg = "#d0d0d0", bg = "#303030", gui = "bold" },
				b = { fg = "#d0d0d0", bg = "#3a3a3a" },
				c = { fg = "#d0d0d0", bg = "#303030" },
			},
		}

		require("lualine").setup({
			options = {
				theme = custom_theme,
				component_separators = { "", "" },
				section_separators = { "", "" },
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_c = { { "filename", path = 1 } }, -- Show full path
			},
		})
	end,
}
