--[[
  File: commands.lua
  Description: Custom commands
]]

-- Change colorscheme dark/white mode
vim.api.nvim_create_user_command(
  "BackgroundToggle",
  function()
    vim.o.background = (vim.o.background == "dark") and "light" or "dark"
    -- Unload/Reload plugins to apply palettes colors
    package.loaded["plugins.catppuccin_"] = nil
    package.loaded["catppuccin"] = nil
    require("plugins.catppuccin_")
  end,
  { range = true }
)
