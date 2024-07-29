--[[
  File: lsp.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lsp_config = require("mason-lspconfig")
local lsp_config = require("lspconfig")
local cmp_lsp = require("cmp_nvim_lsp")

local servers = {
  "bashls",
  "dockerls",
  "lua_ls",
  "emmet_ls",
  "gopls",
  "jedi_language_server",
  "ruff_lsp",
  "terraformls",
  "marksman",
  "bashls",
  "ansiblels",
  "dockerls",
  "docker_compose_language_service",
  "yamlls",
  "puppet",
  "jsonls",
  "jinja_lsp",
  "htmx",
  "html",
  "golangci_lint_ls",
}

local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  cmp_lsp.default_capabilities()
)

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
      capabilities=capabilities,
    })
  end,
})


-- Add border to document hover (see: https://github.com/neovim/neovim/pull/13998)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
})

-- vim.lsp.handlers["textDocument/hover"] = ...
-- vim.lsp.handlers["textDocument/signatureHelp"] = ...
