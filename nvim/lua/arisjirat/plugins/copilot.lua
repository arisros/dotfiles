return {
	"github/copilot.vim",
	lazy = false, -- load immediately (Copilot butuh early attach)
	config = function()
		-- =========================
		-- Core Behavior
		-- =========================
		-- Jangan override <Tab>
		-- vim.g.copilot_no_tab_map = true

		-- Disable Copilot by default for some filetypes (optional)
		vim.g.copilot_filetypes = {
			["*"] = true,
			markdown = false,
			text = false,
			gitcommit = false,
		}

		-- =========================
		-- Keymaps (Insert mode)
		-- =========================

		-- -- Accept FULL suggestion (multi-line)
		-- vim.keymap.set(
		-- 	"i",
		-- 	"<C-Space>",
		-- 	'copilot#Accept("")',
		-- 	{ expr = true, silent = true, desc = "Copilot Accept (full)" }
		-- )
		--
		-- -- Accept only ONE line (optional)
		-- vim.keymap.set(
		-- 	"i",
		-- 	"<C-CR>",
		-- 	'copilot#Accept("\\<CR>")',
		-- 	{ expr = true, silent = true, desc = "Copilot Accept (line)" }
		-- )
		--
		-- -- Cycle suggestions
		-- vim.keymap.set("i", "<C-]>", "copilot#Next()", { expr = true, silent = true, desc = "Copilot Next" })
		--
		-- vim.keymap.set("i", "<C-[>", "copilot#Previous()", { expr = true, silent = true, desc = "Copilot Previous" })
		--
		-- -- Dismiss suggestion
		-- vim.keymap.set("i", "<C-c>", "copilot#Dismiss()", { expr = true, silent = true, desc = "Copilot Dismiss" })

		-- =========================
		-- Optional UX Tweaks
		-- =========================

		-- Auto trigger (default true, tapi eksplisit biar jelas)
		-- vim.g.copilot_enabled = true

		-- Delay before suggestion (ms)
		vim.g.copilot_idle_delay = 75

		-- Max lines suggested
		vim.g.copilot_max_lines = 50
	end,
}
