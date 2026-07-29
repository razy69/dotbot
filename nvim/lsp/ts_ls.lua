-- typescript-language-server: TypeScript/TSX LSP wrapper around tsserver
---@type vim.lsp.Config
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}
