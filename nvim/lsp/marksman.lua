-- marksman: Markdown LSP with wiki-link and reference support
---@type vim.lsp.Config
return {
  cmd = { "marksman", "server" },
  filetypes = { "markdown" },
  root_markers = {
    ".marksman.toml",
    ".git",
  },
}
