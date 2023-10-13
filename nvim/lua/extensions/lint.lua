--[[
  File: lint.lua
  Description: An asynchronous linter plugin for Neovim (>= 0.6.0) complementary to the built-in Language Server Protocol support.
  Link: https://github.com/mfussenegger/nvim-lint
]]


local lint = require("lint")

lint.linters_by_ft = {
  ansible = { "ansible_lint" },
  bash = { "shellcheck" },
  golang = { "revive" },
  json = { "jsonlint" },
	lua = { "luacheck" },
  markdown = { "markdownlint" },
  python = { "mypy", "bandit" },
	rst = { "rstlint" },
  sh = { "shellcheck" },
  yaml = { "yamllint" },
}
