vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<ESC>")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Resize windows with h, l, j, k
keymap.set("n", "<leader>rh", "<cmd>vertical resize -10<CR>", { desc = "Decrease window width" })
keymap.set("n", "<leader>rl", "<cmd>vertical resize +10<CR>", { desc = "Increase window width" })
keymap.set("n", "<leader>rj", "<cmd>resize -10<CR>", { desc = "Decrease window height" })
keymap.set("n", "<leader>rk", "<cmd>resize +10<CR>", { desc = "Increase window height" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, silent = true, desc = "Save file" })
keymap.set("n", "<leader>wa", ":wa<CR>", { noremap = true, silent = true, desc = "Save all buffers" })
keymap.set("n", "<leader>e", ":Explore<CR>")
keymap.set("n", "-", ":Explore<CR>", { noremap = true, silent = true, desc = "Open file explorer" })
