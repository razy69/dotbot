--[[
	File: neoclip.lua
	Description: neoclip is a clipboard manager for neovim inspired by for example clipmenu
	Link: https://github.com/AckslD/nvim-neoclip.lua
]]


local neoclip = require("neoclip")

neoclip.setup({
  history = 500,
})
