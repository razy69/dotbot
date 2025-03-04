--[[
  File: commands.lua
  Description: Custom commands
]]


local notify = require("notify")

-- Change colorscheme dark/white mode
vim.api.nvim_create_user_command(
  "BackgroundToggle",
  function()
    vim.o.background = (vim.o.background == "dark") and "light" or "dark"
  end,
  { range = true }
)

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
    notify("Formatting buffer..", "info", {
      title = "Conform.nvim",
    })
    require("conform").format({
      async = true,
      lsp_format = "fallback",
      range = range,
    })
  end,
  { range = true }
)

-- Grep withtout Noice popup and open results in quickfix window
vim.cmd("command! -nargs=+ -complete=file Grep noautocmd silent grep! <args> | redraw! | copen")
vim.cmd("command! -nargs=+ -complete=file LGrep noautocmd silent lgrep! <args> | redraw! | lopen")
