-- Annotation Toolkit
plugin.add({
  name = "neogen",
  src = "https://github.com/danymat/neogen",
  cmd = { "Neogen" },
  config = function()
    require("neogen").setup({
      -- Native vim.snippet: LuaSnip only ships inside the blink_cmp spec
      -- (gated on InsertEnter), so "luasnip" aborted on a cold :Neogen.
      snippet_engine = "nvim",
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
