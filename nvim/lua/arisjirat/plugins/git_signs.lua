return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},

			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 200,
				ignore_whitespace = false,
				use_focus = true,
			},

			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				----------------------------------------------------------------
				-- Navigation
				----------------------------------------------------------------
				map("n", "]h", gs.next_hunk, "Next hunk")
				map("n", "[h", gs.prev_hunk, "Prev hunk")

				----------------------------------------------------------------
				-- Actions: Hunk
				----------------------------------------------------------------
				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")

				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk (visual)")

				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk (visual)")

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

				----------------------------------------------------------------
				-- Actions: Blame / Diff
				----------------------------------------------------------------
				map("n", "<leader>hb", gs.blame_line, "Blame line")
				map("n", "<leader>hB", gs.blame, "Blame buffer")

				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>hd", gs.diffthis, "Diff this")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff against HEAD~")

				----------------------------------------------------------------
				-- Toggles
				----------------------------------------------------------------
				map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle line blame")
				map("n", "<leader>htd", gs.toggle_deleted, "Toggle deleted")

				----------------------------------------------------------------
				-- Text object (underrated but powerful)
				----------------------------------------------------------------
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
			end,
		})
	end,
}
