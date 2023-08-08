--[[
  File: telekasten.lua
  Description: Configuration of Telekasten
  See: https://github.com/renerocksai/telekasten.nvim
]]

local telekasten = require("telekasten")

telekasten.setup({
  home = vim.fn.expand("~/notes"), -- Put the name of your notes directory here
})
