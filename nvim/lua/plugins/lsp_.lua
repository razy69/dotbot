--[[
  File: lsp_.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local lsp_config = require("lspconfig")
local mason_lsp_config = require("mason-lspconfig")
local utils = require("config.utils")
local blink = utils.prequire("blink.cmp")
local blink_capabilities = blink and blink.get_lsp_capabilities() or {}
local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  lsp_config.util.default_config.capabilities,
  blink_capabilities,
  {
    workspace = {
      fileOperations = {
        didRename = true,
        willRename = true,
      },
    },
  }
)

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
  "ruff",
  "jedi_language_server",
  -- Other filetype
  "bashls",
  "lua_ls",
  "marksman",
  "yamlls",
  "jsonls",
  "html",
}

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

require("mason").setup({
  ui = {
    border = "single",
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

local navic = utils.prequire("nvim-navic")
if navic then
  navic.setup({
    lsp = {
      auto_attach = true,
      preference = servers,
    },
    highlight = true,
    depth_limit = 5,
    lazy_update_context = true,
  })
end

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
        if navic and client.server_capabilities["documentSymbolProvider"] then
          navic.attach(client, bufnr)
        end
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end,
    })
  end,
})
