return {
	"mistweaverco/kulala.nvim",
	keys = { "<leader>Rs", "<leader>Ra", "<leader>Ro" },
	ft = { "http", "rest" },
	opts = {
		-- your configuration comes here
		global_keymaps = true,
	},
	-- function(opts)
	-- 	-- require("kulala").setup(opts)gcc
	-- 	-- send leader kll to open the kulala
	-- 	local function open_kulala()
	-- 		require("kulala").open()
	-- 	end
	-- 	vim.api.nvim_set_keymap("n", "<leader>fll", open_kulala, { noremap = true, silent = true })
	-- end,
}
