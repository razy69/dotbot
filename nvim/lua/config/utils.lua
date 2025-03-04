--[[
	File: utils.lua
	Description: Some usefule func
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

return M
