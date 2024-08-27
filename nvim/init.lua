--[[
  File: init.lua
  Description: Entry point file for neovim
  Boilerplate: https://github.com/tokiory/neovim-boilerplate
]]

-- Patched font to set (for icons display)
-- https://www.nerdfonts.com/font-downloads

-- Settings
require("settings")
require("filetypes")

-- Bootsraping plugin manager
require("lazy-bootstrap")

-- Commands and AutoCommands
require("autocmd")
require("commands")

-- Keymap
require("keybindings")
