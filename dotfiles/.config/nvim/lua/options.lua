-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!


-- Enable mouse mode for normal and visual mode
vim.o.mouse = 'v'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Keep signcolumn on by default 
-- This is for displaying additional left col for errors git etc.
vim.wo.signcolumn = 'yes'

-- Make line numbers default
vim.wo.number = true
-- current selected line always 0, helps with navigation
vim.wo.relativenumber = true

-- Set highlight on search
vim.o.hlsearch = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- spell checker
vim.o.spell = true

-- show additional hidden lines of texe when scrolling
vim.o.scrolloff = 8

-- fold functions and classes with: `za` keybord shortcut
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99

vim.o.colorcolumn = "79"

-- set colorscheme
vim.o.background = "dark" -- or "light" for light mode
  require("gruvbox").setup({
    transparent_mode = true,
  })
vim.cmd("colorscheme gruvbox")
