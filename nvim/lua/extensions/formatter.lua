--[[
  File: formatter.lua
  Description: A format runner for Neovim.
  Link: https://github.com/mhartington/formatter.nvim
]]

--local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
--local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

local formatter = require("formatter")

formatter.setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    python = {
      require("formatter.filetypes.python").isort,
      require("formatter.filetypes.python").black,
    },
  }
}
