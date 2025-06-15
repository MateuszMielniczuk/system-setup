-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Insert Mode ---------------------------------------------------------------
------------------------------------------------------------------------------

local map = vim.keymap.set

-- press `jk` or `kj` fast to exit insert mode
map("i", "jk", "<esc>", { desc = "Exit insert_mode" })
map("i", "kj", "<esc>", { desc = "Exit insert_mode" })

-- vim.api.nvim_set_keymap(
--     "n",
--     "<leader>kk",
--     '<cmd>lua require("plugins.show_kyria").show_kyria()<cr>',
--     { noremap = true, silent = true }
-- )
vim.keymap.set("n", "<leader>kk", function()
    require("modules.show_kyria").show_kyria()
end, { desc = "Show Kyria Layout" })
