--[[
  File: gitsigns.lua
  Description: Configuration of gitsigns
  See: https://github.com/lewis6991/gitsigns.nvim
]]

local gitsigns = require("gitsigns")

gitsigns.setup({
  signs = {
    add          = { text = '▍' },
    change       = { text = '▍' },
    delete       = { text = '▍' },
    topdelete    = { text = '▍' },
    changedelete = { text = '▍' },
    untracked    = { text = '▍' },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "right_align",
    virt_text_priority = 1,
    delay = 2000,
    ignore_whitespace = false,
  },
  signcolumn = true,
  watch_gitdir = {
    follow_files = true
  },
  attach_to_untracked = true,
})
