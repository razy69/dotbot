--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

local telescope = require("telescope")

telescope.setup{
  defaults = {
    borderchars = { "█", " ", "▀", "█", "█", " ", " ", "▀" },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
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
    ["fzf"] = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
  },
}

telescope.load_extension("noice")
telescope.load_extension("projects")
telescope.load_extension("ui-select")
telescope.load_extension("media_files")
telescope.load_extension("undo")
telescope.load_extension("neoclip")
telescope.load_extension("fzf")
