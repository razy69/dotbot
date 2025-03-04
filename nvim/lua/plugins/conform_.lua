--[[
  File: conform_.lua
  Description: Configuration of conform.nvim
  See: https://github.com/stevearc/conform.nvim
]]

local conform = require("conform")
local utils = require("config.utils")
local notify = utils.prequire("notify")

conform.setup({
  default_format_opts = {
    timeout_ms = 3000,
    async = true,            -- not recommended to change
    quiet = false,           -- not recommended to change
    lsp_format = "fallback", -- not recommended to change
  },
  notify_on_error = true,
  notify_no_formatters = true,
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 500,
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
  formatter_by_ft = {
    ["_"] = { "trim_newlines", "trim_whitespace" },
    lua = { "stylua" },
    python = { "isort", "ruff_format" },
    rust = { "rustfmt", lsp_format = "fallback" },
    json = { "fixjson" },
    go = { "goimports", "gofmt" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    yaml = { "yamlfix" },
  },
})

vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

-- Format buffer using Conform.nvim
vim.api.nvim_create_user_command(
  "Format",
  function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end

    if notify then
      notify("Formatting buffer..", "info", {
        title = "Conform.nvim",
      })
    end

    conform.format({
      async = true,
      lsp_format = "fallback",
      range = range,
    })
  end,
  { range = true }
)
