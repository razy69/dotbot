--[[
  File: gitsigns.lua
  Description: Configuration of gitsigns
  See: https://github.com/lewis6991/gitsigns.nvim
]]

local gitsigns = require("gitsigns")
local null_ls = require("null-ls")

gitsigns.setup{
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
    delay = 1000,
    ignore_whitespace = false,
  },
}

null_ls.setup{
  sources = {
    null_ls.builtins.code_actions.gitsigns,
  }
}
