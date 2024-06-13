--[[
  File: commands.lua
  Description: Custom commands
]]

require "helpers/globals"

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })


vim.api.nvim_create_user_command("BackgroundToggle", function(args)
  vim.o.background = (vim.o.background == "dark") and "light" or "dark"
  color_palette = (vim.o.background == "dark") and "frappe" or "latte"
  require("tiny-devicons-auto-colors").setup({
    colors = require("catppuccin.palettes").get_palette(color_palette)
  })
end, { range = true })
