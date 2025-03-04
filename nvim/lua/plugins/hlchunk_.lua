--[[
  File: hlchunk_.lua
  Description: Highlight the indent line, and highlight the code chunk according to the current cursor position
  See: https://github.com/shellRaining/hlchunk.nvim
]]

require("hlchunk").setup({
  indent = {
    enable = true,
    use_treesitter = false,
    chars = { "│" },
  },
})
