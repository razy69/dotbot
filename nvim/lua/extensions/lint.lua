--[[
  File: lint.lua
  Description: An asynchronous linter plugin for Neovim (>= 0.6.0) complementary to the built-in Language Server Protocol support.
  Link: https://github.com/mfussenegger/nvim-lint
]]

--local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

local lint = require("lint")

lint.linters_by_ft = {
  python = { "mypy" },
  markdown = { "markdownlint" },
}

-- Lint on Leave Insert Mode
autocmd("BufWritePost" , {
  callback = function()
    lint.try_lint()
  end
})
