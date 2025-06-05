--[[
	File: autocmd.lua
	Description: Various utils for autocmd.
]]

local M = {}

-- Helper to ceate augroup (from LazyVim)
---@param name any
---@return integer
function M.augroup(name)
  return vim.api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

return M
