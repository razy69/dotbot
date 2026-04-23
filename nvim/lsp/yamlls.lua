-- yaml-language-server: YAML LSP with schema validation (Red Hat)
---@type vim.lsp.Config
return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_dir = vim.fs.root(0, {
    ".git",
  }),
  single_file_support = true,
  settings = {
    -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
    redhat = { telemetry = { enabled = false } },
  }
}
