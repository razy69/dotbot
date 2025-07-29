--[[
  File: lazy_bootstrap.lua
  Description: Bootstrap and setup lazy.nvim.
  See: https://github.com/folke/lazy.nvim
]]

-- Define Leader Key before lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins._config" }, -- Plugins list
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
  checker = { enabled = true },
  ui = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    size = {
      width = 0.8,
      height = 0.8,
    },
  },
  rocks = {
    enabled = true,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
      },
    },
  },
})
