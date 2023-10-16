--[[
  File: monokai.lua
  Description: Configuration Monokai Pro theme
  See: https://github.com/loctvl842/monokai-pro.nvim
]]

local monokai = require("monokai-pro")

monokai.setup({
  devicons = true,
  styles = {
    comment = { italic = false },
    keyword = { italic = false },       -- any other keyword
    type = { italic = false },          -- (preferred) int, long, char, etc
    storageclass = { italic = false },  -- static, register, volatile, etc
    structure = { italic = false },     -- struct, union, enum, etc
    parameter = { italic = false },     -- parameter pass in function
    annotation = { italic = false },
    tag_attribute = { italic = false }, -- attribute of tag in reactjs
  },
  filter = "ristretto",
  background_clear = {},
  inc_search = "underline", -- underline | background
})

vim.cmd([[colorscheme monokai-pro]])
