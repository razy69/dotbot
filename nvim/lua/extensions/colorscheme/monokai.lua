--[[
  File: monokai.lua
  Description: Configuration Monokai Pro theme
  See: https://github.com/loctvl842/monokai-pro.nvim
]]

local monokai = require("monokai-pro")

monokai.setup({
  transparent_background = false,
  terminal_colors = true,
	devicons = true,
  styles = {
    comment = { italic = false },
    keyword = { italic = false }, -- any other keyword
    type = { italic = false }, -- (preferred) int, long, char, etc
    storageclass = { italic = false }, -- static, register, volatile, etc
    structure = { italic = false }, -- struct, union, enum, etc
    parameter = { italic = false }, -- parameter pass in function
    annotation = { italic = false },
    tag_attribute = { italic = false }, -- attribute of tag in reactjs
  },
  filter = "spectrum",
  background_clear = {},
  plugins = {
    bufferline = {
      underline_selected = false,
      underline_visible = false,
    },
    indent_blankline = {
      context_highlight = "pro", -- default | pro
      context_start_underline = false,
    },
  },
})

cmd.colorscheme("monokai-pro")
