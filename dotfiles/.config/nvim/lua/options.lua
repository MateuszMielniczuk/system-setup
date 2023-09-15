-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!


-- Enable mouse mode for normal and visual mode
vim.o.mouse = 'v'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Better editor UI
-- Make line numbers default
vim.wo.number = true
-- current selected line always 0, helps with navigation
vim.wo.relativenumber = true
-- This is for displaying additional left col for errors git etc.
vim.wo.signcolumn = 'yes'

-- Set highlight on search
vim.o.hlsearch = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time between two key presses
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
-- Enable 24-bit colors in terminal
vim.o.termguicolors = true

-- spell checker
vim.o.spell = true

-- show additional hidden lines of text when scroll
vim.o.scrolloff = 8

-- fold functions and classes with: `za` keybord shortcut
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99

-- draw line to see max code line
vim.o.colorcolumn = "79"

