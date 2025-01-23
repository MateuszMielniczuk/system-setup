-- INFO: This file contains all the options that are set in Neovim

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

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard:append("unnamedplus")

-- Draw line to see max code line
-- opt.colorcolumn = "80"

-- Set to have a better completion experience
opt.completeopt = "menuone,noselect"

opt.conceallevel = 0 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line

-- opt.expandtab = true -- Use spaces instead of tabs

-- Fold functions and classes with: `za` keybord shortcut
opt.foldmethod = "indent"
opt.foldlevel = 99

-- Set highlight on search
opt.hlsearch = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true

opt.incsearch = true -- search like in modern browser

-- Enable mouse mode for normal and visual mode
opt.mouse = "v"

vim.wo.number = true -- Print line numbers

opt.pumheight = 10 -- Popup menu height

-- Current selected line always 0, helps with navigation
vim.wo.relativenumber = true

opt.ruler = false -- Don't show the ruler

opt.showmode = false -- Dont show mode since we have a statusline

-- Show additional hidden lines of text when scroll
opt.scrolloff = 8
opt.sidescrolloff = 8

-- This is for displaying additional left col for errors git etc.
vim.wo.signcolumn = "yes"

opt.smartcase = true -- Don't ignore case with capitals

-- opt.smartindent = true -- Insert indents automatically

opt.spell = true -- spell check

opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- NOTE: You should make sure your terminal supports this
-- Enable 24-bit colors in terminal
opt.termguicolors = true

-- Speed must be under 500ms inorder for keys to work, increase if you are not
-- able to.
opt.timeoutlen = 300

-- Save undo history
opt.undofile = true

-- Faster completion time
opt.updatetime = 250

-- if a file is being edited by another program (or was written to file while
-- editing with another program), it is not allowed to be edited
vim.opt.writebackup = false
