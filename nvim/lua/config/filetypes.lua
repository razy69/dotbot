--[[
  File: filetypes.lua
  Description: Custom filetype configuration
]]

-- Define gitconfig ft for '.git/config'
vim.filetype.add({
  filename = {
    [".git/config"] = "gitconfig",
    ["gitconfig"] = "gitconfig",
  },
})
