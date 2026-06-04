local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

vim.o.timeoutlen = 1000

-- Use the system clipboard for all yank/paste. "unnamedplus" targets the
-- CLIPBOARD register on Linux (needs xclip/wl-clipboard, both in debian.txt)
-- and maps to the system pasteboard on macOS — so copy/paste works the same
-- on both. ("unnamed" alone would use Linux's PRIMARY selection instead.)
vim.opt.clipboard = "unnamedplus"

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- vim.g.lazyvim_php_lsp = "intelephense"

-- Disable unused providers to suppress checkhealth warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
