-- docker-langserver: Dockerfile LSP with syntax and lint support
---@type vim.lsp.Config
return {
  mason = "dockerfile-language-server",
  cmd = { "docker-langserver", "--stdio" },
  filetypes = { "dockerfile" },
  -- `.git` fallback matters: a bare "Dockerfile" marker misses Dockerfile.dev,
  -- Containerfile, and Dockerfiles living in a subdirectory.
  root_markers = { "Dockerfile", ".git" },
}
