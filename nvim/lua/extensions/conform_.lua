--[[
  File: conform_.lua
  Description: Configuration of conform.nvim
  See: https://github.com/stevearc/conform.nvim
]]

local conform = require("conform")

conform.setup({
  formatter_by_ft = {
    ["*"] = { "trim_newlines", "trim_whitespace" },
    lua = { "stylua" },
    python = { "isort", "ruff_format" },
    rust = { "rustfmt", lsp_format = "fallback" },
    json = { "fixjson" },
    go = { "goimports", "gofumpt" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    yaml = { "yamlfix" },
  },
})

vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
