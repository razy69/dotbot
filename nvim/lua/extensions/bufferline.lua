--[[
  File: bufferline.lua
  Description: Bufferline configuration
  See: https://github.com/akinsho/bufferline.nvim
]]

require("bufferline").setup {
  options = {
    mode = "tabs",
    show_buffer_close_icons = true,
    show_close_icon = true,
    enforce_regular_tabs = true,
  }
}
