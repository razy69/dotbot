-- Code formatter with per-filetype configuration
plugin.add({
  name = "conform",
  src = "https://github.com/stevearc/conform.nvim",
  cmd = { "Format" },
  keys = {
    { "<leader>f", desc = "Format buffer" },
  },
  config = function()
    local conform = require("conform")
    conform.setup({
      default_format_opts = {
        timeout_ms = 3000,
        async = true,            -- not recommended to change
        quiet = false,           -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      notify_on_error = true,
      notify_no_formatters = true,
      formatters_by_ft = {
        ["_"] = { "trim_newlines", "trim_whitespace" },
        go = { "goimports", "gofmt" },
        json = { "fixjson" },
        lua = { "stylua" },
        python = { "ruff_format" }, -- ruff handles import sorting via isort rules
        rust = { "rustfmt", lsp_format = "fallback" },
        sh = { "shfmt" },
        terraform = { "terraform_fmt" },
        yaml = { "yamlfix" },
      },
    })

    vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

    -- Declare the Mason-installable formatters so :FormatInstall / :MasonStatus
    -- can see them, matching how lsp/ and linters/ are handled. Omitted on
    -- purpose: gofmt and rustfmt ship with their toolchains, terraform_fmt uses
    -- the terraform binary, ruff is already declared by linters/ruff.lua, and
    -- trim_newlines/trim_whitespace are built into conform.
    require("commands.mason").register("format", {
      { pkg = "stylua",    binary = "stylua" },
      { pkg = "goimports", binary = "goimports" },
      { pkg = "shfmt",     binary = "shfmt" },
      { pkg = "fixjson",   binary = "fixjson" },
      { pkg = "yamlfix",   binary = "yamlfix" },
    })

    -- Format buffer using Conform.nvim
    vim.api.nvim_create_user_command(
      "Format",
      function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1] or ""
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end

        vim.notify("Formatting buffer..", vim.log.levels.INFO, {
          title = "Conform.nvim",
        })

        conform.format({
          async = true,
          lsp_format = "fallback",
          range = range,
        })
      end,
      { range = true }
    )

    -- Add keymap
    utils.wk_add({
      { "<leader>f", "<cmd>Format<cr>", desc = "Format buffer", mode = { "n" } }
    })
  end,
})
