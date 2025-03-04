--[[
  File: illuminate.lua
  Description: Automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
  See: https://github.com/RRethy/vim-illuminate
]]

require("illuminate").configure({
  delay = 200,
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
