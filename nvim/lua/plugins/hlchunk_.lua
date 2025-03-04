--[[
  File: hlchunk.lua
  Description: Highlight the indent line, and highlight the code chunk according to the current cursor position
  See: https://github.com/shellRaining/hlchunk.nvim
]]

require("hlchunk").setup({
  exclude_filetypes = {
    help = true,
    alpha = true,
    neotree = true,
    lazy = true,
    mason = true,
    notify = true,
    noice = true,
  },
  chunk = {
    enable = false,
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
  line_num = {
    enable = false,
    use_treesitter = true,
  }
})
