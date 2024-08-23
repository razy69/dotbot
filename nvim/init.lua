--[[
  File: init.lua
  Description: Entry point file for neovim
  Boilerplate: https://github.com/tokiory/neovim-boilerplate
]]

-- Patched font to set (for icons display)
-- https://www.nerdfonts.com/font-downloads

-- Bootsraping plugin manager
require("lazy-bootstrap")

-- Settings
require("settings")
require("filetypes")

-- Plugin management
local lazy = require("lazy")
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
lazy.setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
  ui = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    size = {
      width = 0.8,
      height = 0.8,
    },
  },
  rocks = {
    enabled = false,
  },
})

-- Colorscheme
vim.cmd("colorscheme catppuccin")

-- Commands and AutoCommands
require("autocmd")
require("commands")

-- Keymap
require("keybindings")
