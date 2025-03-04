--[[
  File: barbecue.lua
  Description: VS Code like winbar that uses nvim-navic in order to get LSP context from your language server.
  See: https://github.com/utilyre/barbecue.nvim
]]

local navic = require("nvim-navic")
local barbecue = require("barbecue")
local servers = {
  "bashls",
  "dockerls",
  "lua_ls",
  "emmet_ls",
  "gopls",
  "jedi_language_server",
  "ruff_lsp",
  "terraformls",
}

navic.setup {
  lsp = {
    auto_attach = true,
    preference = servers,
  },
}

barbecue.setup({
  show_dirname = false,
  show_basename = false,
})
