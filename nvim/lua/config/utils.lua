--[[
	File: utils.lua
	Description: Some usefull func.
]]

local M = {}

-- Helper to load module without error
-- Return nil if module is not found
-- Usage:
--   local utils = require("config.utils")
--   local mod = utils.prequire("module")
--   if mod then
--     ...
--   end
function M.prequire(m)
  local ok, err = pcall(require, m)
  if not ok then return nil, err end
  return err
end

function M.get_flavor()
  return (vim.o.background == "dark") and "frappe" or "latte"
end

function M.get_palette()
  local palettes = require("catppuccin.palettes")
  local flavor = M.get_flavor()
  return palettes.get_palette(flavor)
end

return M
