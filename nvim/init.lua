--[[
  File: init.lua
  Description: Entry point file for neovim
  Boilerplate: https://github.com/tokiory/neovim-boilerplate
]]

-- Patched font to set (for icons display)
-- https://www.nerdfonts.com/font-downloads

-- vim.opt
require("config.options")

-- lazy plugins
require("plugins._bootstrap")

-- custom filetypes
require("config.filetypes")

-- autocmd
require("config.autocmd")

-- treesitter
require("config.treesitter")

-- lsp
require("config.lsp")
