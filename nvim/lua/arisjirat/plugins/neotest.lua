-- neotest + playwright adapter — run a single E2E spec from the buffer instead
-- of retyping `bun playwright test -g '...'` in another pane.
--
-- Prefix is <leader>T, not <leader>t: core/keymaps.lua already owns <leader>t
-- for tab management (to/tx/tn/tp/tf).
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"thenbe/neotest-playwright",
			dependencies = "nvim-telescope/telescope.nvim",
		},
	},
	-- neotest detects a file's language from its PATH (vim.filetype.match with no
	-- buffer), and on nvim 0.11 that returns nil for .ts — the extension is
	-- ambiguous (TypeScript vs MPEG transport stream), so nvim defers to a
	-- content check that needs a buffer neotest doesn't have. The result is a
	-- spec file that appears in the summary tree but expands to nothing and runs
	-- nothing. Pinning the extension makes path-based detection deterministic.
	init = function()
		vim.filetype.add({
			extension = {
				ts = "typescript",
				mts = "typescript",
				cts = "typescript",
				tsx = "typescriptreact",
			},
		})
	end,
	keys = {
		{
			"<leader>Tr",
			function()
				require("neotest").run.run()
			end,
			desc = "Test: run nearest",
		},
		{
			"<leader>Tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Test: run file",
		},
		{
			"<leader>Tl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Test: run last",
		},
		{
			"<leader>TS",
			function()
				require("neotest").run.stop()
			end,
			desc = "Test: stop",
		},
		{
			"<leader>Ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Test: summary",
		},
		{
			"<leader>To",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Test: output",
		},
		{
			"<leader>TO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Test: output panel",
		},
		{
			"<leader>Tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Test: watch file",
		},
		{ "<leader>Tp", "<cmd>NeotestPlaywrightProject<cr>", desc = "Test: playwright project" },
		{ "<leader>TP", "<cmd>NeotestPlaywrightPreset<cr>", desc = "Test: playwright preset" },
		-- Specs under generated/ appear only after `sut gen` — refresh picks them
		-- up without restarting nvim.
		{ "<leader>TR", "<cmd>NeotestPlaywrightRefresh<cr>", desc = "Test: refresh spec list" },
	},
	config = function()
		-- Position parsing normally happens in a child `nvim --embed --headless
		-- -n -u NONE`, which by definition never sees the filetype fix in init()
		-- above — so every .ts spec failed to parse there ("get_lang: expected
		-- string, got nil") and the summary showed files that expanded to nothing.
		-- Parse in this process instead. These specs are small; the blocking cost
		-- is not measurable, and correctness beats it either way.
		local ok_lib, lib = pcall(require, "neotest.lib")
		if ok_lib then
			lib.subprocess.init = function() end
			lib.subprocess.enabled = function()
				return false
			end
		end

		local playwright = require("neotest-playwright")

		local adapter = playwright.adapter({
			options = {
				persist_project_selection = true,
				enable_dynamic_test_discovery = true,

				-- super-test drives playwright through bun, so there is no global
				-- `npx playwright` to fall back on — point at the local binary.
				get_playwright_binary = function()
					return vim.loop.cwd() .. "/node_modules/.bin/playwright"
				end,

				-- Use the repo config so the chromium/msedge projects and the
				-- TEST_VERSION-scoped testMatch are honored. TEST_VERSION itself is
				-- inherited from the shell (~/.supertest).
				get_playwright_config = function()
					return vim.loop.cwd() .. "/playwright.config.ts"
				end,
			},
		})

		local opts = { adapters = { adapter } }

		-- Project (chromium/msedge) selection is an optional consumer; if the
		-- plugin API moves, degrade to plain neotest rather than breaking startup.
		local ok, consumers = pcall(require, "neotest-playwright.consumers")
		if ok and consumers.consumers then
			opts.consumers = { playwright = consumers.consumers }
		end

		require("neotest").setup(opts)
	end,
}
