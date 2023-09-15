-- based on Kickstart.nvim
--
--[[
QUICK HELP
  If you don't know much about Lua a read this guide.
  - https://learnxinyminutes.com/docs/lua/

  You can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html

  - Run `:help <command>` and read that help section for more information.
--]]

-- import files from folder ./lua/

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
--  Plugin list is defined in lua/plugins folder
require('lazy').setup("plugins")

require("options")
require("keymaps")
require("autocommand")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
