--[[
  File: lsp-lines.lua
  Description: Configuration of LSP lines
  See: https://git.sr.ht/~whynothugo/lsp_lines.nvim
]]

local lsp_lines = require("lsp_lines")

-- Disable virtual_text since it's redundant due to lsp_lines.
vim.diagnostic.config({
    virtual_text = false,
})

lsp_lines.setup()
