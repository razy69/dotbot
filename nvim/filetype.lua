--[[
  File: filetype.lua
  Description: Custom filetype definition.
]]

-- Core already maps '.git/config' via a pattern, and only handles
-- '/etc/gitconfig' for the bare name — hence just the basename here.
vim.filetype.add({
  filename = {
    ["gitconfig"] = "gitconfig",
  },
})

vim.filetype.add({
  extension = {
    gpg = "gpg"
  },
})
