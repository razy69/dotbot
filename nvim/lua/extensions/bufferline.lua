--[[
  File: bufferline.lua
  Description: Bufferline configuration
  See: https://github.com/akinsho/bufferline.nvim
]]

require("bufferline").setup({
  options = {
    mode = "tabs",
    show_buffer_close_icons = false,
    show_close_icon = false,
    enforce_regular_tabs = true,
  },
  highlights = require("catppuccin.groups.integrations.bufferline").get(),
})
