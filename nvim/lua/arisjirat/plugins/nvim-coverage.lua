return {
	"andythigpen/nvim-coverage",
	version = "*",
	config = function()
		local cov = require("coverage").setup({
			auto_reload = true,
			highlights = {
				covered = {
					-- no-color
					fg = "#000000",
				},
				uncovered = {
					-- blue #0000ff
					fg = "#006ee6",
				},
			},
			-- coverage_file = "coverage-vitest/lcov.info",
			-- load_file = "coverage_vitest/lcov.info",
			load_coverage_cb = function()
				-- Load the coverage file
				-- vim.cmd("CoverageLoad")
			end,
		})
		--- Ensure coverage is loaded when opening a file
		-- vim.api.nvim_create_autocmd("BufReadPost", {
		-- 	pattern = "*",
		-- 	callback = function()
		-- 		require("coverage").load()
		--
		-- 		-- Defer execution slightly to allow coverage to be processed
		-- 		vim.defer_fn(function()
		-- 			vim.cmd("Coverage")
		-- 		end, 500) -- Delay for 500ms (adjust as needed)
		-- 	end,
		-- })
	end,
	-- Run :Coverage after LSP is attached and the file is displayed
	-- vim.api.nvim_create_autocmd({ "BufWinEnter", "LspAttach" }, {
	-- 	pattern = "*",
	-- 	once = true, -- Ensures it runs only once per session
	-- 	callback = function()
	-- 		vim.cmd("Coverage")
	-- 	end,
	-- }),
}
