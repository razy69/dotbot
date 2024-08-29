--[[
  File: hlchunk_.lua
  Description: Highlight the indent line, and highlight the code chunk according to the current cursor position
  See: https://github.com/shellRaining/hlchunk.nvim
]]

local hlchunk = require("hlchunk")

hlchunk.setup({
  exclude_filetypes = {
    help = true,
    alpha = true,
    neotree = true,
    lazy = true,
    mason = true,
    notify = true,
  },
  chunk = {
    enable = true,
    style = require("catppuccin.palettes").get_palette("frappe").mauve,
    chars = {
      right_arrow = "─"
    },
    duration = 100,
    delay = 50,
  },
  indent = {
    enable = true,
    chars = { "▏" },
    style = {
      vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
    },
  },
})
