--[[
  File: init.lua
  Description: Entry point file for neovim
  Boilerplate: https://github.com/tokiory/neovim-boilerplate
]]

-- Patched font to set (for icons display)
-- https://www.nerdfonts.com/font-downloads

-- Bootsraping plugin manager
require("lazy-bootstrap")

-- Settings
require("settings")
require("keybindings")
require("autocmd")
require("commands")

-- Plugin management
local lazy = require("lazy")
lazy.setup("plugins")

-- Setup colorscheme
vim.opt.termguicolors = true
vim.cmd("colorscheme sonokai")
vim.cmd("highlight! link Directory White")
vim.cmd("highlight! link NeoTreeDirectoryIcon Grey")
