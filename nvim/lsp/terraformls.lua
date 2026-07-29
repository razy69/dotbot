-- terraform-ls: Official Terraform LSP by HashiCorp
---@type vim.lsp.Config
return {
  cmd = { "terraform-ls", "serve" },
  -- Deliberately narrow: `.tf` files resolve to filetype `terraform`, and
  -- generic `hcl` also covers Packer/Nomad/Vault — starting a Terraform
  -- session on those is wrong.
  filetypes = { "terraform", "terraform-vars" },
  -- Requires a workspace root; no single-file support for Terraform
  workspace_required = true,
  root_markers = {
    ".terraform",
    ".git",
  },
}
