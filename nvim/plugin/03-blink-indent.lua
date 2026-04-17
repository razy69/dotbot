-- Indent guides
plugin.add({
  name = "blink_indent",
  src = "https://github.com/saghen/blink.indent",
  event = plugin.LazyFile,
  config = function()
    require("blink.indent").setup({
      static = {
        char = "▏",
      },
      scope = {
        char = "▏",
      }
    })
  end,
})
