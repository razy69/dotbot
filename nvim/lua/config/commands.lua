--[[
  File: commands.lua
  Description: Custom commands
]]

-- Change colorscheme dark/white mode
vim.api.nvim_create_user_command(
  "BackgroundToggle",
  function()
    vim.o.background = (vim.o.background == "dark") and "light" or "dark"
  end,
  { range = true }
)
