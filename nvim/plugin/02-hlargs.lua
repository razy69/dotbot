-- Highlight function arguments with a distinct color
plugin.add({
  name = "hlargs",
  src = "https://github.com/m-demare/hlargs.nvim",
  config = function()
    -- Configure hlargs
    local colors = utils.get_palette()
    require("hlargs").setup({
      color = colors.maroon,
    })
  end,
})
