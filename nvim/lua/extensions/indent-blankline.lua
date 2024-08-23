--[[
  File: indent-blankline.lua
  Description: Adds indentation guides to Neovim.
  Link: https://github.com/lukas-reineke/indent-blankline.nvim
]]

local ibl = require("ibl")

ibl.setup({
  indent = { char = "▏" },
  scope = { enabled = false },
  exclude = {
    filetypes = {
      "help",
      "alpha",
      "neo-tree",
      "lazy",
      "mason",
      "notify",
    },
  },
})
