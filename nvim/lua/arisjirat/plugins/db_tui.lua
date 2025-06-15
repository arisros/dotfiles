return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		{ "ellisonleao/dotenv.nvim", config = true }, -- ✅ Add this line
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		require("dotenv").setup()

		local dbname = os.getenv("DBUI_NAME")
		local dburl = os.getenv("DBUI_URL")
		if dbname and dburl then
			vim.g.dbs = {
				[dbname] = dburl,
			}
		end
	end,
}
