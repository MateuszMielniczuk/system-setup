-- disable netrw at the very start of your init.lua
-- for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("keymaps")
require("options")
require("plugin-manager")

-- load plugins configurations
require("plug_config.colorscheme")
require("plug_config.file-explorer")
require("plug_config.statusline")
require("plug_config.whichkey")
