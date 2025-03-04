--[[
  File: neogen.lua
  Description: Annotation Toolkit
  Link: https://github.com/danymat/neogen
]]


local neogen = require("neogen")

neogen.setup({
  snippet_engine = "luasnip",
  languages = {
    python = {
      template = {
        annotation_convention = "google_docstrings",
      }
    },
  },
})
