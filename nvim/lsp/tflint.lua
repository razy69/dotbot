-- tflint: Terraform linter with LSP interface
---@type vim.lsp.Config
return {
  cmd = { "tflint", "--langserver" },
  filetypes = { "terraform", "terraform-vars", "tf", "hcl" },
  -- Requires a workspace root; no single-file support for Terraform
  workspace_required = true,
  root_dir = vim.fs.root(0, {
    ".terraform",
    ".tflint.hcl",
    ".git",
  }),
}
