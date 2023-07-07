--[[
  File: lspkind.lua
  Description: LSP Kind plugin configuration
  See: https://github.com/onsails/lspkind.nvim
]]

local lspkind = require("lspkind")

lspkind.init{
  mode = "symbol",
  preset = "codicons",
}