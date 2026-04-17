-- Sort lines/selections with :Sort
plugin.add({
  name = "sort",
  src = "https://github.com/sQVe/sort.nvim",
  cmd = { "Sort" },
  config = function()
    -- Configure sort
    require("sort").setup()
  end,
})
