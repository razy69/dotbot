--[[
	File: fidget.lua
	Description: Extensible UI for Neovim notifications and LSP progress messages.
  See: https://github.com/j-hui/fidget.nvim
]]


local fidget = require("fidget")
fidget.setup({
  integration = {
    ["nvim-tree"] = {
      enable = true,
    },
	},
})
