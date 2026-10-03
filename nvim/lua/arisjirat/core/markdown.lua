local markdown_group = vim.api.nvim_create_augroup("ArisjiratMarkdown", { clear = true })

local function update_wrap(win)
	if vim.w[win].markdown_wrap_pinned then
		return
	end
	local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
	local wide = false
	for _, line in ipairs(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)) do
		if line:match("^%s*|") and vim.fn.strdisplaywidth(line) > width then
			wide = true
			break
		end
	end
	-- render-markdown cannot draw a table whose rows soft wrap
	vim.wo[win][0].wrap = not wide
end

local function copy_link()
	local target = (vim.ui._get_urls and vim.ui._get_urls()[1]) or vim.fn.expand("<cfile>")
	if target == "" then
		return
	end
	vim.fn.setreg("+", target)
	vim.notify("Copied " .. target)
end

vim.api.nvim_create_autocmd("FileType", {
	group = markdown_group,
	pattern = { "markdown" },
	callback = function(event)
		update_wrap(vim.api.nvim_get_current_win())
		vim.opt_local.linebreak = true
		vim.opt_local.breakindent = true
		vim.opt_local.showbreak = "> "
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en" }
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"
		vim.opt_local.colorcolumn = ""

		vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", {
			buffer = event.buf,
			expr = true,
			silent = true,
			desc = "Wrapped down",
		})
		vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", {
			buffer = event.buf,
			expr = true,
			silent = true,
			desc = "Wrapped up",
		})

		vim.keymap.set("n", "<leader>ms", function()
			vim.opt_local.spell = not vim.opt_local.spell:get()
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Toggle markdown spell",
		})

		vim.keymap.set("n", "<leader>mw", function()
			vim.w.markdown_wrap_pinned = true
			vim.opt_local.wrap = not vim.opt_local.wrap:get()
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Toggle markdown wrap",
		})

		local link_pattern = [=[\[[^]]*\](\|\%(\](\)\@<!\<https\?://]=]
		vim.keymap.set("n", "]u", function()
			vim.fn.search(link_pattern, "W")
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Next markdown link",
		})
		vim.keymap.set("n", "[u", function()
			vim.fn.search(link_pattern, "bW")
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Previous markdown link",
		})

		vim.keymap.set("n", "<leader>ml", copy_link, {
			buffer = event.buf,
			silent = true,
			desc = "Copy markdown link",
		})

		vim.keymap.set("n", "<leader>mr", function()
			if vim.fn.exists(":RenderMarkdown") > 0 then
				vim.cmd("RenderMarkdown toggle")
			end
		end, {
			buffer = event.buf,
			silent = true,
			desc = "Toggle markdown render",
		})
	end,
})

vim.api.nvim_create_autocmd("WinResized", {
	group = markdown_group,
	callback = function()
		for _, win in ipairs(vim.v.event.windows) do
			if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "markdown" then
				update_wrap(win)
			end
		end
	end,
})
