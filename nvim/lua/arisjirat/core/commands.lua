vim.api.nvim_create_user_command("FormatJson", function()
	-- 1. Set filetype
	vim.cmd("set ft=json")

	-- 2. Enable wrapping
	vim.cmd("set wrap linebreak")

	-- 3. Format using conform, fallback to jq if conform not installed
	local ok, conform = pcall(require, "conform")
	if ok then
		conform.format({ async = true, lsp_fallback = true })
	else
		vim.cmd("%!jq .")
	end
end, {})
