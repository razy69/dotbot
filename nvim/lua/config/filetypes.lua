--[[
  File: filetypes.lua
  Description: Custom filetype definition.
]]

-- Define gitconfig ft for '.git/config'
vim.filetype.add({
  filename = {
    [".git/config"] = "gitconfig",
    ["gitconfig"] = "gitconfig",
  },
})

vim.filetype.add({
  extension = {
    gpg = "gpg"
  },
})
