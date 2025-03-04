--[[
  File: session-manager.lua
  Description: Configuration of Neovim Session Manager
  Link: https://github.com/Shatur/neovim-session-manager
]]

local Path = require("plenary.path")
local config = require("session_manager.config")

require("session_manager").setup({
  autoload_mode = config.AutoloadMode.Disabled
})

