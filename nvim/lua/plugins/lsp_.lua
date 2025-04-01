--[[
  File: lsp_.lua
  Description: Configure LSP with lspconfig and install tools with Mason.
  Link:
    https://github.com/neovim/nvim-lspconfig
    https://github.com/williamboman/mason.nvim
]]

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
  "perlnavigator",
}

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
    textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
  }
)

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

require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
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

local navic_on_attach = function(client, bufnr)
  if navic and client.server_capabilities["documentSymbolProvider"] then
    navic.attach(client, bufnr)
  end
end

local lspconfig = require("lspconfig")
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup{
    on_attach = navic_on_attach,
    capabilities = default_capabilities,
  }
end
