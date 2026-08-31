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

-- Chat
keymap.set("n", "<leader>ac", "<cmd>ChatGPT<CR>", { desc = "AI Chat" })
keymap.set("n", "<leader>aa", "<cmd>ChatGPTActAs<CR>", { desc = "AI Act As" })

-- Edit (visual)
keymap.set("v", "<leader>ae", "<cmd>ChatGPTEditWithInstructions<CR>", { desc = "AI Edit (diff)" })

-- Quick actions
keymap.set("n", "<leader>ax", "<cmd>ChatGPTRun explain_code<CR>", { desc = "AI Explain Code" })
keymap.set("n", "<leader>af", "<cmd>ChatGPTRun fix_bugs<CR>", { desc = "AI Fix Bugs" })
keymap.set("n", "<leader>ao", "<cmd>ChatGPTRun optimize_code<CR>", { desc = "AI Optimize" })
-- g
-- need completion code here
-- keymap.set("n", "<leader>ag", "<cmd>ChatGPTRun generate_tests<CR>", { desc = "AI Generate Tests" })
-- keymap.set("n", "<leader>ar", "<cmd>ChatGPTRun refactor_code<CR>", { desc = "AI Refactor Code" })
-- keymap.set("n", "<leader>as", "<cmd>ChatGPTRun suggest_tests<CR>", { desc = "AI Suggest Tests" })
-- keymap.set("n", "<leader>at", "<cmd>ChatGPTRun translate_code<CR>", { desc = "AI Translate Code" })
-- keymap.set("n", "<leader>acm", "<cmd>ChatGPTRun code_review<CR>", { desc = "AI Code Review" })
-- keymap.set("n", "<leader>ail", "<cmd>ChatGPTRun improve_language<CR>", { desc = "AI Improve Language" })
-- keymap.set("n", "<leader>awd", "<cmd>ChatGPTRun write_documentation<CR>", { desc = "AI Write Documentation" })
-- keymap.set("n", "<leader>asb", "<cmd>ChatGPTRun suggest_better_variable_names<CR>", { desc = "AI Suggest Better Variable Names" })
-- keymap.set("n", "<leader>acc", "<cmd>ChatGPTRun convert_code<CR>", { desc = "AI Convert Code" })
-- keymap.set("n", "<leader>ais", "<cmd>ChatGPTRun improve_security<CR>", { desc = "AI Improve Security" })
-- keymap.set("n", "<leader>apd", "<cmd>ChatGPTRun debug_code<CR>", { desc = "AI Debug Code" })
-- keymap.set("n", "<leader>apg", "<cmd>ChatGPTRun paraphrase_text<CR>", { desc = "AI Paraphrase Text" })
-- keymap.set("n", "<leader>asl", "<cmd>ChatGPTRun summarize_text<CR>", { desc = "AI Summarize Text" })
-- keymap.set("n", "<leader>aoc", "<cmd>ChatGPTRun outline_code<CR>", { desc = "AI Outline Code" })
--
--
