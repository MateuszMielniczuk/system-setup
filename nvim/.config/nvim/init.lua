-- disable netrw at the very start of your init.lua
-- for nvim-tree
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

require("keymaps")
require("options")
require("plugin-manager")

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
vim.cmd(
    [[
    hi clear SpellBad
    hi SpellBad cterm=underline
    hi SpellBad gui=undercurl
    ]]
)

-- run this command after installing pylsp by mason
-- PylspInstall pyls-flake8 pyls-isort pyls-mypy python-lsp-black python-lsp-ruff

-- also need configurotion in pyproject.toml file
-- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
