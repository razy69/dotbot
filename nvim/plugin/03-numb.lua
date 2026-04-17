-- Peek at line numbers when typing :<number>
plugin.add({
  name = "numb",
  src = "https://github.com/nacro90/numb.nvim",
  event = plugin.LazyFile,
  config = function()
    require("numb").setup()
  end,
})
