--[[
  File: init.lua
  Description: Entry point file for neovim
  Boilerplate: https://github.com/tokiory/neovim-boilerplate
]]

-- Patched font to set (for icons display)
-- https://www.nerdfonts.com/font-downloads

-- Options
require("config.options")
require("config.filetypes")

-- Plugins
require("plugins._bootstrap")

-- Commands
require("config.autocmd")
require("config.commands")

-- keybindings
require("config.keybindings")
