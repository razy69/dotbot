--[[
  File: lsp.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lsp_zero = require("lsp-zero")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_config = require("lspconfig")
local servers = {
  "bashls",
  "dockerls",
  "lua_ls",
  "emmet_ls",
  "gopls",
  "jedi_language_server",
  "ruff_lsp",
  "terraformls",
}

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
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
  ensure_installed = servers,
})

for _, lsp in ipairs(servers) do
  lsp_config[lsp].setup {
    capabilities = capabilities,
  }
end
