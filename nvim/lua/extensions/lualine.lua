--[[
  File: lualine.lua
  Description: Neovim statusline configuration
  See: https://github.com/nvim-lualine/lualine.nvim
]]

local lualine = require("lualine")
local navic = require("nvim-navic")

lualine.setup({
  icons_enabled = true,
  theme = "monokai-pro",
  extensions = {
    "neo-tree",
    "trouble"
  },
  sections = {
    lualine_a = {
      {
        "mode"
      },
    },
    lualine_b = {
      {
        "branch"
      },
      {
        "diff"
      },
      {
        "diagnostics",
        symbols = {error = " ", warn = " ", info = " ", hint = " "},
      },
    },
    lualine_c = {
      {
        "filename",
        file_status = true,
        path = 1,
      },
      {
        function()
          return navic.get_location()
        end,
        cond = function()
          return navic.is_available()
        end
      },
    },
  },
})
