-- gopls: Official Go language server
---@type vim.lsp.Config
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  root_markers = {
    ".golangci.yml",
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",
    "go.work",
    "go.mod",
    ".git",
  },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        nilness      = true,
        unusedwrite  = true,
      },
      -- Enable all inlay hint categories for Go constructs
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      staticcheck = true,
      gofumpt = true,
      codelenses = {
        generate = true,
        gc_details = true,
        test = true,
        tidy = true,
      },
    }
  }
}
