-- Add/change/delete surrounding pairs (brackets, quotes, tags)
plugin.add({
  name = "nvim_surround",
  src = "https://github.com/kylechui/nvim-surround",
  event = plugin.LazyFile,
  config = function()
    require("nvim-surround").setup({})
  end,
})
