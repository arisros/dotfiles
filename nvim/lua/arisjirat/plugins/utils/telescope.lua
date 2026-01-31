local function lsp_references_dynamic_width()
	local fname_width = 30

	-- Coba ambil lebar pane tmux
	local ok, pane_width = pcall(function()
		return tonumber(vim.fn.system("tmux display -p '#{pane_width}'"))
	end)

	if ok and pane_width and pane_width > 0 then
		fname_width = math.floor(pane_width / 2)
	end

	require("telescope.builtin").lsp_references({
		fname_width = fname_width,
	})
end

return {
	lsp_references_dynamic_width = lsp_references_dynamic_width,
}
