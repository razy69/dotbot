--[[
  File: conform.lua
  Description: Lightweight yet powerful formatter plugin for Neovim.
  Link: https://github.com/stevearc/conform.nvim
]]


local conform = require("conform")
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

conform.setup({
  format_on_save = false,
  formatters_by_ft = {
    bash = { "shfmt" },
    golang = { "gofmt" },
    json = { "fixjson" },
    lua = { "stylua" },
    python = { "isort", "black" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    yaml = { "yamlfix" },
    ["_"] = { "trim_whitespace", "trim_newlines" },
  },
})
