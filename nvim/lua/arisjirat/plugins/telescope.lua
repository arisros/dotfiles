return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
		keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
		keymap.set("n", "<leader>fl", "<cmd>Telescope lsp_document_symbols<cr>")

		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local finders = require("telescope.finders")
		local pickers = require("telescope.pickers")
		local previewers = require("telescope.previewers")
		local conf = require("telescope.config").values

		local function list_unsaved_buffers()
			local buffers = {}

			-- Get all buffers and filter unsaved ones
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[bufnr].buflisted and vim.bo[bufnr].modified then
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					if bufname == "" then
						bufname = "[No Name]"
					end -- Handle unnamed buffers
					table.insert(buffers, { bufnr = bufnr, name = bufname })
				end
			end

			if #buffers == 0 then
				vim.notify("No unsaved buffers!", vim.log.levels.INFO)
				return
			end

			-- Use Telescope to show unsaved buffers
			pickers
				.new({}, {
					prompt_title = "Unsaved Buffers",
					finder = finders.new_table({
						results = buffers,
						entry_maker = function(entry)
							return {
								value = entry.bufnr,
								ordinal = entry.name,
								display = "[+] " .. entry.name, -- Mark unsaved buffers
								bufnr = entry.bufnr,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					previewer = previewers.new_buffer_previewer({
						define_preview = function(self, entry)
							vim.api.nvim_win_set_buf(self.state.winid, entry.bufnr)
						end,
					}),
					attach_mappings = function(_, map)
						-- Open selected buffer
						map("i", "<CR>", function(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							vim.api.nvim_set_current_buf(selection.bufnr)
						end)

						-- Delete buffer with `<C-d>`
						map("i", "<C-d>", function(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							vim.api.nvim_buf_delete(selection.bufnr, { force = false })
							actions.close(prompt_bufnr)
						end)

						return true
					end,
				})
				:find()
		end

		vim.api.nvim_create_user_command("TelescopeUnsavedBuffers", list_unsaved_buffers, {})
		vim.keymap.set("n", "<leader>fu", ":TelescopeUnsavedBuffers<CR>", { noremap = true, silent = true })
	end,
}
