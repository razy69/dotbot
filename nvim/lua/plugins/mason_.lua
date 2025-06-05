--[[
  File: mason_.lua
  Description: Configure LSP with lspconfig and install tools with Mason.
  Link: https://github.com/williamboman/mason.nvim
]]

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

-- Define Lsp server binaries to install based on Lsp config filenames
local servers = {}
local lsp_configs_dir = vim.fn.stdpath("config") .. "/lsp"
for _, file in ipairs(vim.fn.readdir(lsp_configs_dir)) do
  if file:match("%.lua$") then
    local server = file:gsub("%.lua$", "")
    table.insert(servers, server)
  end
end

-- Install LSP Servers
require("mason-lspconfig").setup({
  automatic_installation = true,
  automatic_enable = true,
  ensure_installed = servers,
})
