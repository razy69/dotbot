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
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lsp", [[v:val =~ "\.lua$"]])) do
  local server = file:gsub("%.lua$", "")
  table.insert(servers, server)
end

-- Install LSP Servers
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
})
