--[[
  File: mason.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local lsp_config = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lsp_zero = require("lsp-zero")
local lua_opts = lsp_zero.nvim_lua_ls()

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({ buffer = bufnr })
end)

mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_lspconfig.setup({
  handlers = {
    lsp_zero.default_setup,
  },
  ensure_installed = {
    "bashls",               -- LSP for Bash
    "dockerls",             -- LSP for Docker
    "lua_ls",               -- LSP for Lua
    "emmet_ls",             -- LSP for Emmet (Vue, HTML, CSS)
    "gopls",                -- LSP for Go
    "yamlls",               -- LSP for YAML
    "jsonls",               -- LSP for JSON
    "jedi_language_server", -- LSP for Python
    "ruff_lsp",             -- LSP for Python
    "terraformls",          -- LSP for Terraform
  },
})

lsp_config.lua_ls.setup(lua_opts)
