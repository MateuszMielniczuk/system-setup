-- [[ Basic Keymaps ]]

local opts = { noremap = true, silent = true }

-- Shorten function name
-- See `:help vim.keymap.set()`
local keymap = vim.keymap.set

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --------------------------------------------------------------------
------------------------------------------------------------------------------

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts) -- left window
keymap("n", "<C-k>", "<C-w>k", opts) -- up window
keymap("n", "<C-j>", "<C-w>j", opts) -- down window
keymap("n", "<C-l>", "<C-w>l", opts) -- right window

-- navigate buffers
keymap("n", "<tab>", ":bnext<cr>", opts) -- Next Tab
keymap("n", "<s-tab>", ":bprevious<cr>", opts) -- Previous tab

-- move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts) -- Alt-j
keymap("n", "<A-k>", ":m .-2<CR>==", opts) -- Alt-k

-- Insert --------------------------------------------------------------------
------------------------------------------------------------------------------

-- press jk fast to exit insert mode
keymap("i", "jk", "<esc>", opts) -- Insert mode -> jk -> Normal mode
keymap("i", "kj", "<esc>", opts) -- Insert mode -> kj -> Normal mode

-- Visual --------------------------------------------------------------------
------------------------------------------------------------------------------

-- stay in indent mode, so not escaping from selection
keymap("v", "<", "<gv", opts) -- Right Indentation
keymap("v", ">", ">gv", opts) -- Left Indentation

-- move text up and down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- -- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
