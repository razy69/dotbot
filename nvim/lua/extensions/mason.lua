--[[
  File: mason.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local lint = require("lint")
local formatter = require("formatter")

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand


-- Linters {{{
lint.linters_by_ft = {
  python = { "mypy" },
  markdown = { "markdownlint" },
}

-- Lint on Leave Insert Mode
autocmd("BufWritePost" , {
  callback = function()
    lint.try_lint()
  end
})
-- }}}


-- Formatters {{{
formatter.setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    python = {
      require("formatter.filetypes.python").isort,
      require("formatter.filetypes.python").black,
    },
  }
}

-- fmt on save
augroup("FormatAutogroup", { clear = true })
autocmd("BufWritePost", {
  group = "FormatAutogroup",
  command = "FormatWriteLock",
})
-- }}}

-- Mason Setup + LSP {{{
mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "󰄾",
      package_uninstalled = "󰅖"
    }
  }
})

mason_lspconfig.setup{
  ensure_installed = {
    "bashls",               -- LSP for Bash
    "dockerls",             -- LSP for Docker
    "lua_ls",               -- LSP for Lua
    "emmet_ls",             -- LSP for Emmet (Vue, HTML, CSS)
    "gopls",                -- LSP for Go
    "yamlls",               -- LSP for YAML
    "jsonls",               -- LSP for JSON
    "jedi_language_server", -- LSP for Python
    "ruff_lsp",             -- LSP for Python
    "terraformls",          -- LSP for Terraform
  }
}


-- Setup LSP config
local capabilities = require("cmp_nvim_lsp").default_capabilities()

mason_lspconfig.setup_handlers({
  function(server_name)
    local opts = {
      capabilities = capabilities,
    }

    if server_name == "lua_ls" then
      opts["settings"] = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      }
    end

    lspconfig[server_name].setup(opts)
  end,
})
-- }}}


-- Default diagnostics config {{{
local diagnostics_opts = {
  severity_sort = true,
  signs = true,
  virtual_text = {
    spacing = 4,
    prefix = "▎",
    format = function(diagnostic)
      return string.format(
        "%s (%s)",
        diagnostic.message,
        diagnostic.source
      )
    end,
  },
  float = {
    border = "none",
    format = function(diagnostic)
      return string.format(
        "%s (%s)",
        diagnostic.message,
        diagnostic.source
      )
    end,
  },
}

vim.diagnostic.config(diagnostics_opts)
-- }}}
