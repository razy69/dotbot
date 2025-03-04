--[[
  File: lsp-zero.lua
  Description: Configure easily configure LSP Mason/Nvim-Cmp
  Link: https://github.com/VonHeikemen/lsp-zero.nvim
]]

local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
