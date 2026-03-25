return {
	"echasnovski/mini.map",
	event = "VimEnter",
	config = function()
		local map = require("mini.map")
		local map_width = 10

		map.setup({
			integrations = {
				map.gen_integration.builtin_search(),
				map.gen_integration.diagnostic(),
				map.gen_integration.gitsigns(),
			},
			symbols = {
				encode = map.gen_encode_symbols.dot("4x2"),
				scroll_line = "▶",
				scroll_view = "┃",
			},
			window = {
				focusable = false,
				side = "right",
				width = map_width,
				winblend = 15,
				show_integration_count = false,
			},
		})

		-- Right-side padding split so buffer text wraps before the minimap
		local pad_buf = nil
		local pad_wins = {}

		local function get_pad_win()
			local tp = vim.api.nvim_get_current_tabpage()
			local w = pad_wins[tp]
			if w and vim.api.nvim_win_is_valid(w) then
				return w
			end
			pad_wins[tp] = nil
			return nil
		end

		local function create_padding()
			if get_pad_win() then
				return
			end
			local cur_win = vim.api.nvim_get_current_win()
			if not pad_buf or not vim.api.nvim_buf_is_valid(pad_buf) then
				pad_buf = vim.api.nvim_create_buf(false, true)
				vim.bo[pad_buf].buftype = "nofile"
				vim.bo[pad_buf].bufhidden = "hide"
				vim.bo[pad_buf].swapfile = false
				vim.bo[pad_buf].buflisted = false
				vim.api.nvim_buf_set_name(pad_buf, "[minimap-pad]")
			end
			vim.cmd("botright vertical " .. map_width .. "split")
			local pw = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(pw, pad_buf)
			vim.wo[pw].winfixwidth = true
			vim.wo[pw].number = false
			vim.wo[pw].relativenumber = false
			vim.wo[pw].signcolumn = "no"
			vim.wo[pw].foldcolumn = "0"
			vim.wo[pw].cursorline = false
			vim.wo[pw].colorcolumn = ""
			vim.wo[pw].statusline = " "
			vim.wo[pw].winhighlight = "Normal:NormalFloat"
			pad_wins[vim.api.nvim_get_current_tabpage()] = pw
			vim.api.nvim_set_current_win(cur_win)
		end

		local function remove_padding()
			local pw = get_pad_win()
			if pw then
				vim.api.nvim_win_close(pw, true)
				pad_wins[vim.api.nvim_get_current_tabpage()] = nil
			end
		end

		-- Prevent focus on the padding window
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				local cur_win = vim.api.nvim_get_current_win()
				local pw = get_pad_win()
				if cur_win == pw then
					vim.cmd("wincmd h")
				end
			end,
		})

		-- Wrap open/close/toggle to manage the padding split
		local orig_open = map.open
		local orig_close = map.close

		map.open = function(...)
			create_padding()
			orig_open(...)
		end

		map.close = function(...)
			orig_close(...)
			remove_padding()
		end

		map.toggle = function(...)
			if MiniMap.current.win_data[vim.api.nvim_get_current_tabpage()] then
				map.close()
			else
				map.open()
			end
		end

		map.open()

		vim.keymap.set("n", "<leader>mo", map.open, { desc = "Minimap open" })
		vim.keymap.set("n", "<leader>mc", map.close, { desc = "Minimap close" })
		vim.keymap.set("n", "<leader>mt", map.toggle, { desc = "Minimap toggle" })
		vim.keymap.set("n", "<leader>mr", map.refresh, { desc = "Minimap refresh" })
		vim.keymap.set("n", "<leader>mf", map.toggle_focus, { desc = "Minimap toggle focus" })
		vim.keymap.set("n", "<leader>ms", map.toggle_side, { desc = "Minimap toggle side" })
	end,
}
