---@type vim.lsp.Config
return {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "terraform-vars" },
  workspace_required = true,
  root_dir = vim.fs.root(0, {
    ".terraform",
    ".git",
  }),
}
