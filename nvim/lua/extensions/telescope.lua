--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

local telescope = require("telescope")
local trouble = require("trouble.sources.telescope")

telescope.setup({
  defaults = {
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    mappings = {
      i = { ["<c-t>"] = trouble.open },
      n = { ["<c-t>"] = trouble.open },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown{}
    },
    ["undo"] = {
      mappings = {
        i = {
          ["<s-cr>"] = require("telescope-undo.actions").yank_additions,
          ["<c-cr>"] = require("telescope-undo.actions").yank_deletions,
          ["<cr>"] = require("telescope-undo.actions").restore
        },
      },
    },
  },
})

telescope.load_extension("noice")
telescope.load_extension("projects")
telescope.load_extension("ui-select")
telescope.load_extension("media_files")
telescope.load_extension("undo")
telescope.load_extension("refactoring")
