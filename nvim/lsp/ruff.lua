---@type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, {
    "ruff.toml",
    ".ruff.toml",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }),
  single_file_support = true,
  settings = {
    organizeImports = true,
  },
}
