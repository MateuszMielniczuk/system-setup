-- [[ Setting options ]]
-- See `:help vim.o`
local opt = vim.opt

-- Enable break indent
vim.o.breakindent = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- draw line to see max code line
vim.o.colorcolumn = "80"

-- Set to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line

-- opt.expandtab = true -- Use spaces instead of tabs

-- fold functions and classes with: `za` keybord shortcut
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99

-- Set highlight on search
vim.o.hlsearch = false

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true

-- Enable mouse mode for normal and visual mode
vim.o.mouse = 'v'

vim.wo.number = true -- Print line numbers

-- current selected line always 0, helps with navigation
vim.wo.relativenumber = true

opt.showmode = false -- Dont show mode since we have a statusline

-- show additional hidden lines of text when scroll
vim.o.scrolloff = 8

-- This is for displaying additional left col for errors git etc.
vim.wo.signcolumn = 'yes'

vim.o.smartcase = true -- Don't ignore case with capitals

-- opt.smartindent = true -- Insert indents automatically

vim.o.spell = true -- spell check

opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- NOTE: You should make sure your terminal supports this
-- Enable 24-bit colors in terminal
vim.o.termguicolors = true

-- speed must be under 500ms inorder for keys to work, increase if you are not able to.
vim.o.timeoutlen = 300

-- Save undo history
vim.o.undofile = true

 -- Save swap file and trigger CursorHold
vim.o.updatetime = 250

