--[[
  File: lint.lua
  Description: An asynchronous linter plugin for Neovim (>= 0.6.0) complementary to the built-in Language Server Protocol support.
  Link: https://github.com/mfussenegger/nvim-lint
]]


local lint = require("lint")
local mason_lint = require("mason-nvim-lint")

lint.linters_by_ft = {
  bash = { "shellcheck" },
  json = { "jsonlint" },
  lua = { "luacheck" },
  markdown = { "markdownlint" },
  python = { "mypy" },
  sh = { "shellcheck" },
  yaml = { "yamllint" },
}

mason_lint.setup({
  ensure_installed = {
    -- Linters
    "markdownlint", -- Markdown
    "mypy",         -- Python
    "luacheck",     -- Lua
    "shellcheck",   -- sh/Bash
    "yamllint",     -- Yaml
    "jsonlint",     -- Json
  }
})
