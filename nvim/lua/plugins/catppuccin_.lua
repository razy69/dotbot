--[[
  File: catppuccin_.lua
  Description: Catppuccin theme for (Neo)vim.
  Link: https://github.com/catppuccin/nvim
]]

local utils = require("config.utils")
local flavor = utils.get_flavor()
local colors = utils.get_palette()

require("catppuccin").setup({
  flavour = flavor,
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
    blink_cmp = true,
    flash = true,
    fzf = true,
    gitsigns = true,
    illuminate = {
      enabled = true,
      lsp = false,
    },
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    lsp_trouble = true,
    lsp_saga = true,
    markdown = true,
    mason = true,
    neotree = true,
    noice = true,
    notify = true,
    native_lsp = {
      enabled = true,
      inlay_hints = {
        background = true,
      },
    },
    nvim_surround = true,
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
      BlinkCmpSource = { fg = colors.lavender },
      BlinkCmpMenu = { fg = colors.text, bg = colors.base },
      BlinkCmpMenuBorder = { fg = colors.blue, bg = colors.base },
      BlinkCmpDoc = { fg = colors.text, bg = colors.base },
      BlinkCmpDocSeparator = { fg = colors.pink, bg = colors.base },
      BlinkCmpDocBorder = { fg = colors.blue, bg = colors.base },
      BlinkCmpSignatureHelp = { fg = colors.text, bg = colors.base },
      BlinkCmpSignatureHelpBorder = { fg = colors.blue, bg = colors.base },
      BlinkCmpSignatureHelpActiveParameter = { fg = colors.mauve },
      FloatBorder = { fg = colors.blue, bg = colors.base },
      GitSignsCurrentLineBlame = { fg = colors.sapphire },
      IBLIndentGuide1 = { fg = colors.surface1 },
      NoiceMini = { bg = colors.base },
      NormalFloat = { fg = colors.text, bg = colors.base },
      WhichKey = { fg = colors.yellow },
      WhichKeySeparator = { fg = colors.pink },
      WhichKeyValue = { fg = colors.subtext1 },
      WhichKeyDesc = { fg = colors.text },
    },
  },
})

vim.cmd("colorscheme catppuccin")
