-- Highlight and search TODO/FIXME/HACK comments
plugin.add({
  name = "todo_comments",
  src = "https://github.com/folke/todo-comments.nvim",
  deps = { "plenary" },
  event = plugin.LazyFile,
  config = function()
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
        pattern = [[\b(KEYWORDS)(\(\w*\))?:]],
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
  end,
})
