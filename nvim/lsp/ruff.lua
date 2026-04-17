-- Python linter via Ruff (diagnostics only, formatting handled by conform)
---@type vim.lsp.Config
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "setup.py",
    ".git",
  }),
  single_file_support = true,
  settings = {
    ruff = {
      lint = {
        enable = true,
      },
    },
  },
}
