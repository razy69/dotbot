--[[
  File: catppuccin_.lua
  Description: Catppuccin theme for (Neo)vim.
  Link: https://github.com/catppuccin/nvim
]]

local palettes = require("catppuccin.palettes")
local colors = (vim.o.background == "dark") and palettes.get_palette("frappe") or palettes.get_palette("latte")

require("catppuccin").setup({
  flavour = "frappe", -- latte, frappe, macchiato, mocha
  background = {      -- :h background
    light = "latte",
    dark = "frappe",
  },
  transparent_background = false, -- disables setting the background color.
  show_end_of_buffer = true,      -- shows the "~" characters after the end of buffers
  term_colors = true,             -- sets terminal colors (e.g. `g:terminal_color_0`)
  dim_inactive = {
    enabled = true,               -- dims the background color of inactive window
    shade = "dark",
    percentage = 0.45,            -- percentage of the shade to apply to the inactive window
  },
  compile = {
    enabled = true,
    path = vim.fn.stdpath("cache") .. "/catppuccin",
  },
  no_italic = true,    -- Force no italic
  no_bold = false,     -- Force no bold
  no_underline = true, -- Force no underline
  integrations = {
    alpha = true,
    barbecue = {
      dim_dirname = true, -- directory name is dimmed by default
      bold_basename = true,
      dim_context = false,
      alt_background = true,
    },
    blink_cmp = true,
    fidget = true,
    flash = true,
    fzf = true,
    gitsigns = true,
    illuminate = {
      enabled = true,
      lsp = true,
    },
    lsp_trouble = true,
    mason = true,
    neotree = true,
    noice = true,
    notify = true,
    rainbow_delimiters = true,
    render_markdown = true,
    treesitter = true,
    which_key = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  highlight_overrides = {
    all = {
      BlinkCmpKind = { fg = colors.blue },
      BlinkCmpMenu = { fg = colors.text },
      BlinkCmpMenuBorder = { fg = colors.blue },
      BlinkCmpDocBorder = { fg = colors.blue },
      BlinkCmpSignatureHelpActiveParameter = { fg = colors.mauve },
    },
  },
})

vim.cmd("colorscheme catppuccin")
