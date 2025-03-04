--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

local telescope = require("telescope")
local open_with_trouble = require("trouble.sources.telescope").open

telescope.setup({
  defaults = {
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    mappings = {
      i = { ["<c-t>"] = open_with_trouble },
      n = { ["<c-t>"] = open_with_trouble },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      previewer = false,
      theme = "dropdown",
      ignore_current_buffer = true,
    },
    find_files = { theme = "dropdown", previewer = false },
    git_files = { theme = "dropdown", previewer = false },
    registers = { theme = "dropdown" },
    lsp_code_actions = {
      theme = "cursor",
      layout_config = {
        height = 12,
      },
    },
    lsp_range_code_actions = { theme = "cursor" },
    loclist = { previewer = false },
  },
  extensions = {
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

telescope.load_extension("media_files")
telescope.load_extension("undo")
telescope.load_extension("refactoring")
telescope.load_extension("noice")
