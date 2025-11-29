-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Insert Mode ---------------------------------------------------------------
------------------------------------------------------------------------------

local map = vim.keymap.set

-- press `jk` or `kj` fast to exit insert mode
map("i", "jk", "<esc>", { desc = "Exit insert_mode" })
map("i", "kj", "<esc>", { desc = "Exit insert_mode" })

map("n", "<leader>kk", function()
    require("modules.show_kyria").show_kyria()
end, { desc = "Show Kyria Layout" })

local wk = require("which-key")
wk.add({
    { "<leader>k", group = "MyStuff" }, -- group
})
