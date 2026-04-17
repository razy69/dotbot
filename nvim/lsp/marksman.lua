-- marksman: Markdown LSP with wiki-link and reference support
---@type vim.lsp.Config
return {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_dir = vim.fs.root(0, {
    ".marksman.toml",
    ".git",
  }),
  single_file_support = true,
}
