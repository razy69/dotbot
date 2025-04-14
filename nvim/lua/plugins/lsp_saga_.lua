--[[
  File: lsp_saga_.lua
  Description: Improves the Neovim built-in LSP experience.
  Link: https://github.com/nvimdev/lspsaga.nvim
]]

require("lspsaga").setup {
  ui = {
    kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
  },
  lightbulb = {
    virtual_text = false,
  },
  symbol_in_winbar = {
    folder_level = 3,
  },

}
