---@type vim.lsp.Config
return {
  cmd = { "perlnavigator" },
  filetypes = { "perl" },
  root_dir = vim.fs.root(0, {
    ".git",
  }),
  single_file_support = true,
}
