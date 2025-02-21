return {
	"andythigpen/nvim-coverage",
	version = "*",

	config = function()
		require("coverage").setup({
			auto_reload = false,
			highlights = {
				covered = { fg = "#000000" },
				uncovered = { fg = "#006ee6" },
			},
			-- load_file = "coverage_vitest/lcov.info",
		})
		-- need leader key for show coverage
		vim.api.nvim_set_keymap("n", "<leader>co", ":Coverage<CR>", { noremap = true, silent = true })

		-- Wait until the file is fully loaded and coverage is set up
		-- vim.api.nvim_create_autocmd("BufReadPost", {
		-- 	pattern = "*",
		-- 	callback = function()
		-- 		-- Make sure coverage is loaded
		-- 		require("coverage").load()
		--
		-- 		-- Wait a little for any other plugin (like gitsigns) to finish updating signs
		-- 		vim.schedule(function()
		-- 			vim.cmd("Coverage")
		-- 		end)
		-- 	end,
		-- })
	end,
}
