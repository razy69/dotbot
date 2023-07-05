--[[
  File: monokai.lua
  Description: Configuration Monokai Pro theme
  See: https://github.com/loctvl842/monokai-pro.nvim
]]

local monokai = require("monokai-pro")

monokai.setup({
  transparent_background = false,
  terminal_colors = true,
  filter = "pro",
})

cmd([[colorscheme monokai-pro]])