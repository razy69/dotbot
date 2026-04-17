-- Rendered markdown preview in the buffer
plugin.add({
  name = "markdown",
  src = "https://github.com/MeanderingProgrammer/markdown.nvim",
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown" },
      latex = { enabled = false },
      heading = {
        icons = { " 󰉫 ", " 󰉬 ", " 󰉭 ", " 󰉮 ", " 󰉯 ", " 󰉰 " },
        position = "inline",
      },
      checkbox = {
        unchecked = { icon = "  " },
        checked = { icon = "  " },
      },
    })
  end,
})
