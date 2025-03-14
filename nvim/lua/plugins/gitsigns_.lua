--[[
  File: gitsigns_.lua
  Description: Deep buffer integration for Git.
  Link: https://github.com/lewis6991/gitsigns.nvim
]]

require("gitsigns").setup({
  signs = {
    add          = { text = '▍' },
    change       = { text = '▍' },
    delete       = { text = '▍' },
    topdelete    = { text = '▍' },
    changedelete = { text = '▍' },
    untracked    = { text = '▍' },
  },
  current_line_blame = true,
  current_line_blame_formatter = "  <author> (<author_time:%R>) - <summary>",
})
