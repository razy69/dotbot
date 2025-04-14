--[[
  File: move_.lua
  Description: Gain the power to move lines and blocks!
  Link: https://github.com/fedepujol/move.nvim
]]

require("move").setup({
  line = {
    enable = true, -- Enables line movement
    indent = true  -- Toggles indentation
  },
  block = {
    enable = true, -- Enables block movement
    indent = true  -- Toggles indentation
  },
  word = {
    enable = true, -- Enables word movement
  },
  char = {
    enable = true -- Enables char movement
  }
})
