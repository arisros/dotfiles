return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			current_line_blame = true,
			-- current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 200,
				ignore_whitespace = false,
				virt_text_priority = 100,
				use_focus = true,
			},
			on_attach = function(client)
				local gs = package.loaded.gitsigns

				function map(mode, key, action, desc)
					vim.keymap.set(mode, key, action, { buffer = client, desc = desc })
				end

				-- blame line
				map("n", "<leader>hb", function()
					gs.blame_line()
				end, "Blame current line")
				map("n", "<leader>hB", gs.blame, "Preview hunk")
				map("n", "<leader>hd", gs.diffthis)
			end,
		})
	end,
}
