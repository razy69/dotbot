-- ansible-language-server: Ansible playbook and role LSP
---@type vim.lsp.Config
return {
  cmd = { "ansible-language-server", "--stdio" },
  settings = {
    ansible = {
      python = {
        interpreterPath = "python",
      },
      ansible = {
        path = "ansible",
      },
      -- Disable Ansible Execution Environment (container-based); use local ansible
      executionEnvironment = {
        enabled = false,
      },
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = "ansible-lint",
        },
      },
    },
  },
  filetypes = { "yaml" },
  root_dir = vim.fs.root(0, {
    "ansible.cfg",
    ".ansible-lint",
  }),
  single_file_support = true,
}
