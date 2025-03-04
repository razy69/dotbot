--[[
  File: nvim-ufo.lua
  Description: Make Neovim"s fold look modern and keep high performance.
  Link: https://github.com/kevinhwang91/nvim-ufo
]]


vim.o.foldcolumn = "0" -- "0" is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local ufo = require("ufo")

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return {"treesitter", "indent"}
  end
})
