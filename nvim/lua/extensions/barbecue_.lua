--[[
  File: barbecue.lua
  Description: VS Code like winbar that uses nvim-navic in order to get LSP context from your language server.
  See: https://github.com/utilyre/barbecue.nvim
]]

local barbecue = require("barbecue")

barbecue.setup({
  attach_navic = false,
  create_autocmd = false,
  show_dirname = true,
  show_basename = true,
  exclude_filetypes = { "neo-tree", "alpha" }
})
