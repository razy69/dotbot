-- Highlight other occurrences of the word under cursor
plugin.add({
  name = "vim_illuminate",
  src = "https://github.com/RRethy/vim-illuminate",
  event = plugin.LazyFile,
  config = function()
    require("illuminate").configure({
      delay = 2000,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
      filetypes_denylist = {
        "dirbuf",
        "dirvish",
        "fugitive",
        "neo-tree",
      },
    })
  end,
})
