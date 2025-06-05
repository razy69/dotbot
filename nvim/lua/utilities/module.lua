--[[
  File: module.lua
  Description: Lua module utilities.
]]

local M = {}

-- Helper to load module without error
--
-- Usage:
--   local utils = require("utilities.module")
--   local mod = utils.prequire("a-module-name")
--   if mod then
--     -- module exists
--     ...
--   end
---@param m string
---@return any
function M.prequire(m)
  local exists, mod = pcall(require, m)
  if not exists then
    print("Failed to load module: " .. mod)
    return nil
  else
    return mod
  end
end

return M
