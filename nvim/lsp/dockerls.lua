-- docker-langserver: Dockerfile LSP with syntax and lint support
---@type vim.lsp.Config
return {
  mason = "dockerfile-language-server",
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  root_dir = vim.fs.root(0, {
    "Dockerfile",
  }),
  single_file_support = true,
}
