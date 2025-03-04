--[[
  File: barbecue.lua
  Description: VS Code like winbar that uses nvim-navic in order to get LSP context from your language server.
  See: https://github.com/utilyre/barbecue.nvim
]]

local navic = require("nvim-navic")
local barbecue = require("barbecue")

navic.setup{
  lsp = {
    auto_attach = false,
    preference = {"jedi_language_server", "ruff_lsp"}
  },
}

barbecue.setup({
  show_dirname = false,
  show_basename = false,
})
