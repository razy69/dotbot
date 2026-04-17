-- terraform-ls: Official Terraform LSP by HashiCorp
---@type vim.lsp.Config
return {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "terraform-vars", "tf", "hcl" },
  -- Requires a workspace root; no single-file support for Terraform
  workspace_required = true,
  root_dir = vim.fs.root(0, {
    ".terraform",
    ".git",
  }),
}
