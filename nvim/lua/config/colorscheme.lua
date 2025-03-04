--[[
  File: catppuccin.lua
  Description: Configuration  of catppuccin
  See: https://github.com/catppuccin/nvim
]]

local colors = require("catppuccin.palettes").get_palette("frappe")
local ucolors = require("catppuccin.utils.colors")
local lualine_bg = colors.mantle
local noice_mini_bg = ucolors.lighten(colors.flamingo, 0.1, "#FFFFFF")
local mini_modified_bg = ucolors.lighten(colors.flamingo, 0.3, "#FFFFFF")

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
  no_italic = true,     -- Force no italic
  no_bold = false,      -- Force no bold
  no_underline = true, -- Force no underline
  integrations = {
    barbecue = {
      dim_dirname = true, -- directory name is dimmed by default
      bold_basename = true,
      dim_context = false,
      alt_background = true,
    },
    blink_cmp = true,
    cmp = true,
    noice = true,
    notify = true,
    gitsigns = true,
    treesitter = true,
    fzf = true,
    render_markdown = true,
    lsp_trouble = true,
    rainbow_delimiters = true,
    neotree = true,
    ufo = true,
    illuminate = {
      enabled = true,
      lsp = true,
    },
    which_key = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  highlight_overrides = {
    all = {
      NoiceCmdlinePopup = { bg = noice_mini_bg },
      NoiceMini = { bg = colors.mantle },
      MiniFilesBorder = { bg = noice_mini_bg, fg = noice_mini_bg },
      MiniFilesBorderModified = { bg = mini_modified_bg, fg = mini_modified_bg },
      MiniFilesNormal = { bg = noice_mini_bg },
      MiniFilesModified = { bg = mini_modified_bg },
      MiniFilesCursorLine = { bg = ucolors.lighten(colors.mantle, 0.1, "#FFFFFF") },
      DapSign = { fg = colors.flamingo },
      DapLineStopped = { bg = noice_mini_bg },
      WinBar = { bg = lualine_bg },
      NavicIconsFile = { fg = colors.blue, bg = lualine_bg },
      BlinkCmpKind = { fg = colors.blue },
      BlinkCmpMenu = { fg = colors.text },
      BlinkCmpMenuBorder = { fg = colors.blue },
      BlinkCmpDocBorder = { fg = colors.blue },
      BlinkCmpSignatureHelpActiveParameter = { fg = colors.mauve },
    },
  },
})

vim.cmd("colorscheme catppuccin")
