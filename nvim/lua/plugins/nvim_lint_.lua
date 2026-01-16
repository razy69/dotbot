--[[
  File: nvim_lint_.lua
  Description: An asynchronous linter plugin for Neovim.
  Link: https://github.com/mfussenegger/nvim-lint
]]

local lint = require("lint")
local autocmd_utils = require("utilities.autocmd")

lint.linters_by_ft = {
  bash = { "bash" },
  lua = { "luacheck" },
  markdown = { "vale" },
  -- perl = { "perlcritic", "perlimports" },
  terraform = { "tfsec" },
  yaml = { "yamllint" },
  zsh = { "zsh" },
}

local lint_augroup = autocmd_utils.augroup("lint")
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = lint_augroup,
  callback = function()
    require("lint").try_lint()
  end,
})

-- Lint buffer using nvim-lint
vim.api.nvim_create_user_command(
  "Lint",
  function()
    vim.notify("Lint file..", vim.log.levels.INFO, {
      title = "nvim-lint",
    })
    lint.try_lint()
  end,
  { range = true }
)
