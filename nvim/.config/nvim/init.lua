require("core")
require("plugin-manager")

-- set spell error style to less annoying
vim.cmd([[
    hi clear SpellBad
    hi SpellBad cterm=underline
    hi SpellBad gui=undercurl
    ]])
