--[[
  File: ibl_.lua
  Description: Adds indentation guides to Neovim.
  Link: https://github.com/lukas-reineke/indent-blankline.nvim
]]

require("ibl").setup({
  indent = { char = "│" },
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
