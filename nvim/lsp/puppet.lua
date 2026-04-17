-- puppet-languageserver: Puppet manifest LSP
---@type vim.lsp.Config
return {
  mason = "puppet-editor-services",
  cmd = { "puppet-languageserver", "--stdio" },
  filetypes = { "puppet" },
  root_dir = vim.fs.root(0, {
    "manifests",
    ".puppet-lint.rc",
    "hiera.yaml",
    ".git",
  }),
  single_file_support = true,
}
