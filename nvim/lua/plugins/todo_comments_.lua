--[[
  File: todo_comments_.lua
  Description: Highlight and search for todo comments like TODO, HACK, BUG in your code base.
  Link: https://github.com/folke/todo-comments.nvim
]]

require("todo-comments").setup({
  highlight = {
    -- vimgrep regex, supporting the pattern TODO(name):
    pattern = [[\c.*<((KEYWORDS)%(\(.{-1,}\))?):]],
    comments_only = true,
  },
  keywords = {
    DEPRECATED = {
      icon = "󱒿 ",
      color = "warning",
      alt = { "Deprecated", "deprecated" },
    },
  },
  search = {
    pattern = [[\b(KEYWORDS)(\(\w*\))?*:]],
    command = "rg",
    args = {
      "--color=never",
      "--ignore-case",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
    },
  },
})
