-- Python LSP for completions, go-to-definition, hover, references, and refactoring
---@type vim.lsp.Config
return {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }),
  single_file_support = true,
  settings = {
    jedi = {
      completion = {
        disableSnippets = false,
      },
      diagnostics = {
        enable = false, -- Ruff handles diagnostics
      },
    },
  },
}
