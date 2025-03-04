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

-- New filetype for big file (then autocmd will disable some plugins)
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > vim.g.bigfile_size
            and "bigfile"
            or nil
      end,
    },
  },
})
