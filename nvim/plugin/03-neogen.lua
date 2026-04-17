-- Annotation Toolkit
plugin.add({
  name = "neogen",
  src = "https://github.com/danymat/neogen",
  deps = { "treesitter" },
  cmd = { "Neogen" },
  config = function()
    require("neogen").setup({
      snippet_engine = "luasnip",
      languages = {
        python = {
          template = {
            annotation_convention = "google_docstrings",
          }
        },
      },
    })
  end
})
