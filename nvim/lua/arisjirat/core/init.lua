require("arisjirat/core/keymaps")
require("arisjirat/core/options")
require("arisjirat/core/commands")
require("arisjirat/core/markdown")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.http",
	command = "set filetype=http",
})
