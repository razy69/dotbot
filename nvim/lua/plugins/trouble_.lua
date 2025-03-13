--[[
  File: trouble_.lua
  Description: A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help you solve all the trouble your code is causing.
  Link: https://github.com/folke/trouble.nvim/
]]

require("trouble").setup({
  modes = {
    symbols = {
      win = {
        type = "split",
        relative = "win",
        position = "right",
        size = 0.3,
        pinned = true,
        focus = false,
      },
    },
  },
})
