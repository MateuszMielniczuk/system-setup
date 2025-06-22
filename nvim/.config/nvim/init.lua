-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- make spell errors less annoying
vim.cmd([[
  hi clear SpellBad
  hi SpellBad cterm=underline
  hi SpellBad gui=undercurl
  ]])
