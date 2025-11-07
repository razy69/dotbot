--[[
	File: catppuccin.lua
	Description: Theme helpers.
]]

local M = {}

-- Get catppuccin flavor in function of vim.o.background
---@return string
function M.get_flavor()
  return (vim.o.background == "dark") and "frappe" or "latte"
end

-- Get catppuccin palette in function of vim.o.background
---@return CtpColors<string>|{rosewater: string, flamingo: string, pink: string, mauve: string, red: string, maroon: string, peach: string, yellow: string, green: string, teal: string, sky: string, sapphire: string, blue: string, lavender: string, text: string, subtext1: string, subtext0: string, overlay2: string, overlay1: string, overlay0: string, surface2: string, surface1: string, surface0: string, base: string, mantle: string, crust: string}
function M.get_palette()
  local palettes = require("catppuccin.palettes")
  local flavor = M.get_flavor()
  return palettes.get_palette(flavor)
end

return M
