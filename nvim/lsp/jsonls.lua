-- vscode-json-language-server: JSON/JSONC LSP with schema validation
---@type vim.lsp.Config
return {
  mason = "json-lsp",
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = {
    -- Enable the built-in JSON formatter (disabled by default)
    provideFormatter = true,
  },
}
