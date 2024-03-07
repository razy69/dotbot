--[[
  File: lsp.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_null_ls = require("mason-null-ls")
local null_ls = require("null-ls")
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
}

local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  cmp_lsp.default_capabilities()
)

-- local handlers = {
--   function(server)
--     lsp_config[server].setup({
--       capabilities = capabilities,
--     })
--   end,
-- }

mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_null_ls.setup({
  -- Anything supported by mason.
  ensure_installed = servers,
  automatic_installation = false,
  handlers = {},
})

null_ls.setup({
  -- Anything not supported by mason.
  sources = {}
})

for _, lsp in ipairs(servers) do
  lsp_config[lsp].setup{
    capabilities = capabilities,
    -- handlers = handlers,
  }
end
