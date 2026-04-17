-- golangci-lint-langserver: Bridges golangci-lint with LSP diagnostics
-- Async version detection: kicks off at require-time, defaults to v2 until resolved.
local is_v1 = nil
if vim.fn.executable("go") == 1 then
  local exe = vim.fn.exepath("golangci-lint")
  vim.system({ "go", "version", "-m", exe }, {}, function(result)
    is_v1 = string.match(result.stdout or "", "\tmod\tgithub.com/golangci/golangci%-lint\t") ~= nil
  end)
elseif vim.fn.executable("golangci-lint") == 1 then
  vim.system({ "golangci-lint", "version" }, {}, function(result)
    is_v1 = string.match(result.stdout or "", "version v?1%.") ~= nil
  end)
end

---@type vim.lsp.Config
return {
  cmd = { "golangci-lint-langserver" },
  filetypes = { "go", "gomod" },
  init_options = {
    command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" },
  },
  root_dir = vim.fs.root(0, {
    ".golangci.yml",
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",
    "go.work",
    "go.mod",
    ".git",
  }),
  before_init = function(_, config)
    -- Add support for golangci-lint V1 (in V2 `--out-format=json` was replaced by
    -- `--output.json.path=stdout`). Defaults to v2; overrides only if async detection confirmed v1.
    if is_v1 == true then
      config.init_options.command = { "golangci-lint", "run", "--out-format", "json" }
    end
  end,
}
