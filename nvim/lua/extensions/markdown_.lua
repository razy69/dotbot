--[[
  File: markdown_.lua
  Description: Plugin to improve viewing Markdown files in Neovim
  See: https://github.com/MeanderingProgrammer/render-markdown.nvim
]]

local markdown = require("render-markdown")

markdown.setup({
  file_types = { "markdown", "telekasten" },
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
