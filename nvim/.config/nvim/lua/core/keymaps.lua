-- [[ Basic keymaps ]]

-- Shorten function name
-- See `:help vim.key_map.set()`
local function key_map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
key_map("", "<Space>", "<Nop>")
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
key_map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
key_map("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
key_map("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
key_map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- navigate buffers
key_map("n", "<tab>", ":bnext<cr>", { desc = "Move to next buffer" })
key_map("n", "<s-tab>", ":bprevious<cr>", { desc = "Move to previous buffer" })

-- move text up and down

-- Alt-j
key_map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move selected text down" })

-- Alt-k
key_map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move selected text up" })

key_map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
key_map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
key_map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
key_map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
key_map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- clean highlight from search
key_map("n", "<CR>", ":noh<CR><CR>", { desc = "Clean search highlight" })

-- Insert --------------------------------------------------------------------
------------------------------------------------------------------------------

-- press `jk` or `kj` fast to exit insert mode
key_map("i", "jk", "<esc>", { desc = "Exit insert_mode" })
key_map("i", "kj", "<esc>", { desc = "Exit insert_mode" })

-- Visual --------------------------------------------------------------------
------------------------------------------------------------------------------

-- stay in indent mode, so not escaping from selection
key_map("v", "<", "<gv", { desc = "Indent right" }) -- Right Indentation
key_map("v", ">", ">gv", { desc = "Indent left" }) -- Left Indentation

-- move text up and down
-- key_map("v", "<A-j>", ":m '>+1<CR>gv=gv")
-- key_map("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- -- Remap for dealing with word wrap
-- vim.key_map.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.key_map.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
