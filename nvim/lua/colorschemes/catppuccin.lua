--[[
  File: catppuccin.lua
  Description: Configuration  of catppuccin
  See: https://github.com/catppuccin/nvim
]]

vim.cmd("highlight EoLSpace ctermbg=238 guibg=#cb214e")

require("catppuccin").setup({
    flavour = "frappe", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "frappe",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = true, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    integrations = {
				alpha = true,
        cmp = true,
        gitsigns = true,
        neotree = true,
        treesitter = true,
				treesitter_context = true,
        notify = true,
				fidget = true,
        mason = true,
        ufo = true,
        window_picker = true,
				navic = {
					enabled = true,
					custom_bg = "NONE", -- "lualine" will set background to mantle
				},
				barbecue = {
						dim_dirname = true, -- directory name is dimmed by default
						bold_basename = true,
						dim_context = false,
						alt_background = false,
				},
				indent_blankline = {
						enabled = true,
						scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
						colored_indent_levels = false,
				},
				native_lsp = {
						enabled = true,
						virtual_text = {
								errors = { "italic" },
								hints = { "italic" },
								warnings = { "italic" },
								information = { "italic" },
						},
						underlines = {
								errors = { "underline" },
								hints = { "underline" },
								warnings = { "underline" },
								information = { "underline" },
						},
						inlay_hints = {
								background = true,
						},
				},
        rainbow_delimiters = true,
        telescope = {
					enabled = true,
				},
        illuminate = {
  				enabled = true,
  				lsp = false
				},
				which_key = false,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})
