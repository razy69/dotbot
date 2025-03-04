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
  no_underline = false, -- Force no underline
  integrations = {
    alpha = true,
    cmp = true,
    gitsigns = true,
    neotree = true,
    treesitter = true,
    treesitter_context = true,
    notify = true,
    mason = true,
    ufo = true,
    window_picker = true,
    navic = { enabled = true, custom_bg = "lualine" },
    mini = true,
    noice = true,
    markdown = true,
    telekasten = true,
    indent_blankline = {
      enabled = true,
      scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
      colored_indent_levels = false,
    },
    lsp_trouble = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
        ok = { "underline" },
      },
      inlay_hints = {
        background = true,
      },
    },
    rainbow_delimiters = true,
    telescope = true,
    illuminate = {
      enabled = true,
      lsp = true,
    },
    which_key = true,
    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
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
      TelescopePromptPrefix = { fg = colors.blue },
      TelescopeSelectionCaret = { fg = colors.blue },
    },
  },
})

vim.cmd("colorscheme catppuccin")
