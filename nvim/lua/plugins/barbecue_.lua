--[[
  File: barbecue_.lua
  Description: VS Code like winbar that uses nvim-navic in order to get LSP context from your language server.
  See: https://github.com/utilyre/barbecue.nvim
]]

local autocmd = require("config.autocmd")

require("barbecue").setup({
  attach_navic = false,
  create_autocmd = false,
  show_dirname = true,
  show_basename = true,
  exclude_filetypes = { "neo-tree", "alpha" }
})

-- Barbecue/Navic
local barbecue_group = autocmd.augroup("barbecue")
vim.api.nvim_create_autocmd({
  "WinResized",
  "BufWinEnter",
  "CursorHold",
  "InsertLeave",
}, {
  desc = "Update Barbecue",
  group = barbecue_group,
  callback = function()
    require("barbecue.ui").update()
  end,
})
