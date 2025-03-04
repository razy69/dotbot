--[[
  File: lsp.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lsp_config = require("mason-lspconfig")
local lsp_config = require("lspconfig")
local cmp_lsp = require("cmp_nvim_lsp")
local navic = require("nvim-navic")

local servers = {
  -- IAC
  "puppet",
  "ansiblels",
  "terraformls",
  -- Docker
  "dockerls",
  "docker_compose_language_service",
  -- Golang
  "gopls",
  "golangci_lint_ls",
  -- Python
  "ruff_lsp",
  "jedi_language_server",
  -- Other filetype
  "bashls",
  "lua_ls",
  "marksman",
  "yamlls",
  "jsonls",
  "html",
}

local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  cmp_lsp.default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )
)

navic.setup({
  lsp = {
    auto_attach = true,
    preference = servers,
  },
  highlight = true,
})

mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_lsp_config.setup({
  ensure_installed = servers,
  automatic_installation = true,
  handlers = nil,
})

mason_lsp_config.setup_handlers({
  function(server)
    lsp_config[server].setup({
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 100,
        allow_incremental_sync = true,
      },
      on_attach = function(client, bufnr)
        if client.server_capabilities["documentSymbolProvider"] then
          require("nvim-navic").attach(client, bufnr)
        end
      end,
    })
  end,
})

-- Add border to document hover (see: https://github.com/neovim/neovim/pull/13998)
vim.lsp.handlers["textDocument/foldingRange"] = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = "rounded" }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = "rounded" }
)

vim.lsp.handlers["textDocument/completion/completionItem/snippetSupport"] = true
vim.lsp.handlers["textDocument/completion/completionItem/resolveSupport"] = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}

require("lspconfig.ui.windows").default_options.border = "rounded"
