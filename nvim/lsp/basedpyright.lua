-- basedpyright: Python LSP for completion, navigation, hover, and type checking.
-- Linting is handled by ruff via nvim-lint (see linters/ruff.lua).
-- Formatting is handled by ruff_format via conform (see plugin/03-conform.lua).

local function resolve_venv()
  local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  if not venv or venv == "" then
    return nil, nil
  end
  local sep = vim.fn.has("win32") == 1 and "\\" or "/"
  local bin = vim.fn.has("win32") == 1 and "Scripts" or "bin"
  local python = table.concat({ venv, bin, "python" }, sep)
  if vim.fn.executable(python) == 0 then
    return nil, nil
  end
  return python, venv
end

local python_path, venv_path = resolve_venv()

---@type table
local settings = {
  basedpyright = {
    analysis = {
      typeCheckingMode = "basic",
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
      -- Workspace mode runs full project type-checking, so closed files
      -- contribute diagnostics too. Lives in basedpyright proper; preferred
      -- over neonvim.workspace_diagnostics' hidden-buffer simulation.
      diagnosticMode = "workspace",
      autoImportCompletions = true,
    },
    disableOrganizeImports = true,
  },
}

if python_path and venv_path then
  settings.python = {
    pythonPath = python_path,
    venvPath = vim.fs.dirname(venv_path),
    venv = vim.fs.basename(venv_path),
  }
end

---@type vim.lsp.Config
return {
  -- Mason package is `basedpyright`; the binary it ships is
  -- `basedpyright-langserver`, hence the explicit override.
  mason = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  }),
  single_file_support = true,
  settings = settings,
}
