---@type vim.lsp.Config
return {
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
