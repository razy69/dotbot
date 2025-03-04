--[[
  File: lsp_.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local utils = require("config.utils")
local blink = utils.prequire("blink.cmp")
local default_capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  blink and blink.get_lsp_capabilities() or {},
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

require("mason").setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_installation = true,
})

mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = default_capabilities,
      inlay_hints = {
        enabled = false,
      },
      codelens = {
        enabled = false,
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
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
