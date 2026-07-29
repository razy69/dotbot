-- Mason: package manager for LSP servers, DAP adapters, linters, formatters.
-- Loaded before LSP and nvim-lint (both declare `deps = { "mason" }`).
-- Server/linter install hits `mason-registry` directly from the consumer
-- plugin's config — no `mason-lspconfig` or `mason-tool-installer` layers.
plugin.add({
  name = "mason",
  src = "https://github.com/mason-org/mason.nvim",
  -- No eager load: both consumers declare `deps = { "mason" }` (which resolves
  -- synchronously), so mason is on the rtp with PATH prepended before either
  -- config() runs. These triggers only cover invoking mason directly with no
  -- file open. Commands come from lua/mason/api/command.lua, not a plugin/ dir.
  cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonUpdate", "MasonLog" },
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
