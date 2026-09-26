local function popup(lines)
	vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded", focus_id = "blame_pr" })
end

local function blame_pr(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.fn.fnamemodify(file, ":h")
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local contents = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"

	-- --contents - keeps line numbers right for unsaved edits
	vim.system(
		{ "git", "blame", "--porcelain", "-L", line .. "," .. line, "--contents", "-", "--", file },
		{ cwd = dir, stdin = contents, text = true },
		function(blame)
			local sha = blame.code == 0 and blame.stdout:match("^(%x+)") or nil
			if not sha or sha:match("^0+$") then
				vim.schedule(function()
					vim.notify("Line is not committed yet", vim.log.levels.INFO)
				end)
				return
			end

			vim.system({
				"gh",
				"api",
				"repos/{owner}/{repo}/commits/" .. sha .. "/pulls",
				"--jq",
				'.[0] // empty | "\\(.number)\\t\\(.title)\\t\\(.html_url)\\t\\(.user.login)\\t\\(.merged_at // "not merged")"',
			}, { cwd = dir, text = true }, function(res)
				vim.schedule(function()
					if res.code ~= 0 then
						vim.notify("gh: " .. vim.trim(res.stderr), vim.log.levels.ERROR)
						return
					end
					local out = vim.trim(res.stdout)
					if out == "" then
						popup({ "No PR found for `" .. sha:sub(1, 8) .. "`" })
						return
					end
					local number, title, url, author, merged = unpack(vim.split(out, "\t"))
					popup({
						"**#" .. number .. "** " .. title,
						"",
						url,
						"",
						"by @" .. author .. ", merged " .. merged:sub(1, 10) .. ", commit `" .. sha:sub(1, 8) .. "`",
					})
				end)
			end)
		end
	)
end

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
				map("n", "<leader>hP", function()
					blame_pr(bufnr)
				end, "Blame line PR")

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
