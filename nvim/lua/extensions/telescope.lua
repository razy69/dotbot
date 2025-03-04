--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")

local telescope = require("telescope")

telescope.setup{
  defaults = {
    borderchars = { "█", " ", "▀", "█", "█", " ", " ", "▀" },
    mappings = {
      i = { ["<C-x>"] = trouble.open_with_trouble },
      n = { ["<C-x>"] = trouble.open_with_trouble },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    },
  },
}

telescope.load_extension("noice")
telescope.load_extension("projects")
telescope.load_extension("ui-select")
telescope.load_extension("media_files")
