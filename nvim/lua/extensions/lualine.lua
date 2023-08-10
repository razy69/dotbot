--[[
  File: lualine.lua
  Description: Neovim statusline configuration
  See: https://github.com/nvim-lualine/lualine.nvim
]]

local lualine = require("lualine")

lualine.setup({
  icons_enabled = true,
  theme = "monokai-pro",
  extensions = {
    "lazy", "neo-tree", "nvim-dap-ui",
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
        sources = {"nvim_lsp"},
        symbols = {error = " ", warn = " ", info = " ", hint = " "},
      },
    },
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = false,
        path = 3,
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {"filename"},
    lualine_x = {"location"},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {},
})
