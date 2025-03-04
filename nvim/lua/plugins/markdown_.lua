--[[
  File: markdown_.lua
  Description: Plugin to improve viewing Markdown files in Neovim
  See: https://github.com/MeanderingProgrammer/render-markdown.nvim
]]

require("render-markdown").setup({
  file_types = { "markdown" },
  latex = { enabled = false },
  heading = {
    icons = { " 󰉫 ", " 󰉬 ", " 󰉭 ", " 󰉮 ", " 󰉯 ", " 󰉰 " },
    position = "inline",
  },
  checkbox = {
    unchecked = { icon = "  " },
    checked = { icon = "  " },
  },
})
