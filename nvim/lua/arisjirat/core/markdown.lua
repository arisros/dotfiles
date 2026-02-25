local markdown_group = vim.api.nvim_create_augroup("ArisjiratMarkdown", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = markdown_group,
	pattern = { "markdown" },
	callback = function(event)
		vim.opt_local.wrap = true
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
