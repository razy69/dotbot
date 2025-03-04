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
local formatter_ft_any = require("formatter.filetypes.any")

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

lint.linters_by_ft = {
  python = {"ruff", "mypy",},
  markdown = {"markdownlint",},
}


-- Lint on Leave Insert Mode
autocmd("BufWritePost" , {
  callback = function()
    lint.try_lint()
  end
})

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
formatter.setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    python = {
      require("formatter.filetypes.python").black,
    },
    -- Use the special "*" filetype for defining formatter configurations on
   ["*"] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      formatter_ft_any.remove_trailing_whitespace
    }
  }
}

-- Format on Save
augroup("FormatAutogroup", { clear = true })
autocmd("BufWritePost", {
  group = "FormatAutogroup",
  command = "FormatWriteLock",
})

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
    --"jedi_language_server", -- LSP for Python
    "pyright",              -- LSP for Python
    "terraformls",          -- LSP for Terraform
  }
}

-- Setup every needed language server in lspconfig
mason_lspconfig.setup_handlers{
  function (server_name)
    lspconfig[server_name].setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" }
          },
        },
      },
    }
  end,
}
