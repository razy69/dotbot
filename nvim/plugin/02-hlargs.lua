-- Highlight function arguments with a distinct color
plugin.add({
  name = "hlargs",
  src = "https://github.com/m-demare/hlargs.nvim",
  -- Only meaningful for file buffers. Registered before 02-treesitter.lua
  -- (alphabetical plugin/ order), so its autocmd runs first and hlargs is
  -- loaded by the time treesitter's config calls hlargs.enable_buf().
  event = plugin.LazyFile,
  config = function()
    -- Configure hlargs
    local colors = utils.get_palette()
    require("hlargs").setup({
      color = colors.maroon,
    })
  end,
})
