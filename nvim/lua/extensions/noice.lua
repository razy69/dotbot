--[[
  File: noice.lua
  Description: Noice plugin configuration (with lspconfig)
  See: https://github.com/folke/noice.nvim
]]

local noice = require("noice")

noice.setup{
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
      },
  },
  cmdline = {
    enabled = true, -- enables the Noice cmdline UI
    view = "cmdline",
    conceal = false,
  },
}