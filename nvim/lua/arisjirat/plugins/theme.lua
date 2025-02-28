return {
	"rafi/awesome-vim-colorschemes",
	lazy = false,
	priority = 1000, -- only necessary if you use tairiki as default theme
	config = function()
		vim.cmd([[ colorscheme twilight256 ]])
		-- Apply overrides immediately
		local function apply_highlights()
			vim.api.nvim_set_hl(0, "Identifier", { fg = "#6b99e8", bold = true }) -- Identifier
			vim.api.nvim_set_hl(0, "Function", { fg = "#F0C674", bold = true }) -- Function
			vim.api.nvim_set_hl(0, "Define", { fg = "#ba7d13", bold = true }) -- Define (preprocessor macros, etc.)
			vim.api.nvim_set_hl(0, "Statement", { fg = "#CDA869", bold = true }) -- Statements (if, for, return, etc.)
			vim.api.nvim_set_hl(0, "String", { fg = "#a7b879" }) -- Strings
		end

		apply_highlights() -- Apply once at startup

		-- Auto-apply after colorscheme change
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "twilight256",
			callback = apply_highlights,
		})
	end,
}
-- return {
-- 	"rafi/awesome-vim-colorschemes",
-- 	lazy = false,
-- 	priority = 1000, -- only necessary if you use tairiki as default theme
-- 	config = function()
-- 		-- awesome-vim-colorschemes
-- 		vim.cmd([[
--       colorscheme gruvbox    ]])
-- 	end,
-- }
-- return {
-- 	"deparr/tairiki.nvim",
-- 	lazy = false,
-- 	priority = 1000, -- only necessary if you use tairiki as default theme
-- 	config = function()
-- 		require("tairiki").setup({
-- 			-- optional configuration here
-- 		})
-- 		require("tairiki").load() -- only necessary to use as default theme, has same behavior as ':colorscheme tairiki'
-- 	end,
-- }
-- return {
-- 	"iagorrr/noctishc.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd([[
--       colorscheme noctishc    ]])
-- 	end,
-- }
