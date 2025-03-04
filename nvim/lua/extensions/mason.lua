--[[
  File: mason.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_null_ls = require("mason-null-ls")
local lspconfig = require("lspconfig")

mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_lspconfig.setup{
  ensure_installed = {
    "bashls",               -- LSP for Bash
    "dockerls",             -- LSP for Docker
    "lua_ls",               -- LSP for Lua
    "emmet_ls",             -- LSP for Emmet (Vue, HTML, CSS)
    "jedi_language_server", -- LSP for Python
    "gopls",                -- LSP for Go
    "yamlls",               -- LSP for YAML
    "jsonls",               -- LSP for JSON
    "ruff_lsp",             -- LSP for Python Ruff
    "terraformls",          -- LSP for Terraform
  }
}

mason_null_ls.setup{
  ensure_installed = {
    "mypy",
    "rstcheck",
    "ruff",
    "shellcheck",
    "yamllint",
  }
}

-- Setup every needed language server in lspconfig
mason_lspconfig.setup_handlers{
  function (server_name)
    lspconfig[server_name].setup {}
  end,
}