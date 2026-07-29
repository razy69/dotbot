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

---@type vim.lsp.Config
return {
  -- Mason package is `basedpyright`; the binary it ships is
  -- `basedpyright-langserver`, hence the explicit override.
  mason = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
  settings = settings,
  -- Resolve the interpreter per client start, not at file-load time: Neovim
  -- caches this config for the whole session, so a venv activated later (or a
  -- switch to another project) would otherwise keep the first pythonPath.
  before_init = function(_, config)
    local python_path, venv_path = resolve_venv()
    if not (python_path and venv_path) then
      return
    end
    -- Extend into a fresh table so the module-level `settings` stays pristine
    -- for the next client start.
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      python = {
        pythonPath = python_path,
        venvPath = vim.fs.dirname(venv_path),
      },
    })
  end,
}
