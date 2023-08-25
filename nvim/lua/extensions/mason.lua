--[[
  File: mason.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local get_servers = mason_lspconfig.get_installed_servers
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")


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
    "gopls",                -- LSP for Go
    "yamlls",               -- LSP for YAML
    "jsonls",               -- LSP for JSON
    "jedi_language_server", -- LSP for Python
    "ruff_lsp",             -- LSP for Python
    "terraformls",          -- LSP for Terraform
  }
}

local lsp_flags = {
	allow_incremental_sync = true,
  debounce_text_changes = 150,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

for _, server_name in ipairs(get_servers()) do
  local opts = {}
  opts["capabilities"] = capabilities
	opts["flags"] = lsp_flags

  if server_name == "lua_ls" then
    opts["settings"] = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      },
    }
  end

  lspconfig[server_name].setup(opts)
end
