-- Mason: package manager for LSP servers, DAP adapters, linters, formatters.
-- Loaded before LSP and nvim-lint (both declare `deps = { "mason" }`).
-- Server/linter install hits `mason-registry` directly from the consumer
-- plugin's config — no `mason-lspconfig` or `mason-tool-installer` layers.
plugin.add({
  name = "mason",
  src = "https://github.com/mason-org/mason.nvim",
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "",
          package_pending = "󰄾",
          package_uninstalled = "󰅖",
        },
      },
    })
  end,
})
