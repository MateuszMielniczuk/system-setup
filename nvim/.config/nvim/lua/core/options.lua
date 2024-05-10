-- nvim Explorer showing tree view
vim.cmd("let g:netrw_liststyle = 3")

-- [[ Setting options ]]
-- See `:help opt`
local opt = vim.opt

-- Enable break indent
opt.breakindent = true

-- colorschemes that can use darktheme will use it
opt.background = "dark"

-- allow backspace on indent, end of line or start position
opt.backspace = "indent,eol,start"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
opt.clipboard:append("unnamedplus")

-- draw line to see max code line
opt.colorcolumn = "80"

-- Set to have a better completion experience
opt.completeopt = "menuone,noselect"

-- opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line

-- opt.expandtab = true -- Use spaces instead of tabs

-- fold functions and classes with: `za` keybord shortcut
opt.foldmethod = "indent"
opt.foldlevel = 99

-- Set highlight on search
opt.hlsearch = false

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true

-- Enable mouse mode for normal and visual mode
opt.mouse = "v"

vim.wo.number = true -- Print line numbers

-- current selected line always 0, helps with navigation
vim.wo.relativenumber = true

opt.showmode = false -- Dont show mode since we have a statusline

-- show additional hidden lines of text when scroll
opt.scrolloff = 8

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

-- speed must be under 500ms inorder for keys to work, increase if you are not able to.
opt.timeoutlen = 300

-- Save undo history
opt.undofile = true

-- Save swap file and trigger CursorHold
opt.updatetime = 250
