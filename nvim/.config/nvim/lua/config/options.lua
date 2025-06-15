-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Editing VIM Netrw Explorer
vim.cmd("let g:netrw_liststyle = 3") -- show tree view
-- vim.cmd("let g:netrw_browse_split = 4") -- open in previous window after split
vim.cmd("let g:netrw_keepdir = 0") -- avoid move files error
vim.cmd("let g:netrw_localcopydircmd = 'cp -r'") -- copy directory recursively
vim.cmd("let g:netrw_winsize = 25") -- set netrw window size after split


-- [[ Setting options ]]
-- See `:help opt`
local opt = vim.opt

-- Enable break indent
opt.breakindent = true

-- Colorschemes that can use darktheme will use it
opt.background = "dark"

-- Allow backspace on indent, end of line or start position
opt.backspace = "indent,eol,start"

-- Set highlight on search
opt.hlsearch = true

opt.incsearch = true -- search like in modern browser

-- Enable mouse mode for visual mode
opt.mouse = "v"

-- Show additional hidden lines of text when scroll
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.spell = true -- spell check
opt.spelllang = { "en" }

-- if a file is being edited by another program (or was written to file while
-- editing with another program), it is not allowed to be edited
vim.opt.writebackup = false