---@type vim.lsp.Config
return {
  cmd = { "tflint", "--langserver" },
  filetypes = { "terraform", "terraform-vars", "tf", "hcl" },
  workspace_required = true,
  root_dir = vim.fs.root(0, {
    ".terraform",
    ".tflint.hcl",
    ".git",
  }),
}
