require("keymaps")
require("options")
require("plugin-manager")
require("autocommand")

-- load plugins configurations
require("plug_config.cmp")
require("plug_config.colorizer-setup")
require("plug_config.colorscheme")
require("plug_config.formatter-config")
require("plug_config.fuzzy-finder")
require("plug_config.git-config")
require("plug_config.indent-guide")
require("plug_config.linter")
require("plug_config.lsp")
require("plug_config.mason-setup")
require("plug_config.statusline")
require("plug_config.treesitter-config")
require("plug_config.whichkey")

-- set spell error style to less annoying
vim.cmd([[
    hi clear SpellBad
    hi SpellBad cterm=underline
    hi SpellBad gui=undercurl
    ]])
