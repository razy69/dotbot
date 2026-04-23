-- typescript-language-server: TypeScript/TSX LSP wrapper around tsserver
---@type vim.lsp.Config
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript" },
  root_dir = vim.fs.root(0, {
    ".git",
  }),
}
