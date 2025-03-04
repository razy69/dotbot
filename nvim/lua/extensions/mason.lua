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
    -- LSP
    "bashls",               -- Bash
    "dockerls",             -- Docker
    "lua_ls",               -- Lua
    "emmet_ls",             -- Emmet (Vue, HTML, CSS)
    "gopls",                -- Golang
    "jedi_language_server", -- Python
    "ruff_lsp",             -- Python
    "terraformls",          -- Terraform
  },
})

lsp_config.lua_ls.setup(lua_opts)
