--[[
  File: catppuccin_.lua
  Description: Catppuccin theme for (Neo)vim.
  Link: https://github.com/catppuccin/nvim
]]

local utils = require("utilities.catpuccin")
local flavor = utils.get_flavor()
local colors = utils.get_palette()

-- Add custom highlight groups
vim.api.nvim_set_hl(0, "SymbolUsageRounding", {})
vim.api.nvim_set_hl(0, "SymbolUsageContent", {})
vim.api.nvim_set_hl(0, "SymbolUsageRef", {})
vim.api.nvim_set_hl(0, "SymbolUsageDef", {})
vim.api.nvim_set_hl(0, "SymbolUsageImpl", {})

-- Configure theme
require("catppuccin").setup({
  flavour = flavor,
  transparent_background = false, -- disables setting the background color.
  show_end_of_buffer = false,     -- shows the "~" characters after the end of buffers
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
    blink_cmp = true,
    dap = true,
    dap_ui = true,
    dropbar = { enabled = true, color_mode = true },
    flash = true,
    fzf = true,
    gitsigns = true,
    illuminate = { enabled = true, lsp = false },
    lsp_trouble = true,
    markdown = true,
    mason = true,
    native_lsp = { enabled = true, inlay_hints = { background = false } },
    neotest = true,
    neotree = true,
    noice = true,
    nvim_surround = true,
    rainbow_delimiters = true,
    render_markdown = true,
    snacks = { enabled = true },
    treesitter = true,
    which_key = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  custom_highlights = {
    BlinkCmpDoc = { fg = colors.text, bg = colors.base },
    BlinkCmpDocBorder = { fg = colors.blue, bg = colors.base },
    BlinkCmpDocSeparator = { fg = colors.pink, bg = colors.base },
    BlinkCmpKind = { fg = colors.blue },
    BlinkCmpMenu = { fg = colors.text, bg = colors.base },
    BlinkCmpMenuBorder = { fg = colors.blue, bg = colors.base },
    BlinkCmpSignatureHelp = { fg = colors.text, bg = colors.base },
    BlinkCmpSignatureHelpActiveParameter = { fg = colors.mauve },
    BlinkCmpSignatureHelpBorder = { fg = colors.blue, bg = colors.base },
    BlinkCmpSource = { fg = colors.lavender },
    FloatBorder = { fg = colors.blue, bg = colors.base },
    GitSignsCurrentLineBlame = { fg = colors.sky, bg = colors.base },
    ModesVisual = { fg = colors.mauve, bg = colors.mauve },
    ModesReplace = { fg = colors.yellow, bg = colors.yellow },
    NoiceMini = { bg = colors.base },
    NormalFloat = { fg = colors.text, bg = colors.base },
    SnacksIndent = { fg = colors.surface1 },
    SnacksIndentScope = { fg = colors.overlay1 },
    SymbolUsageRounding = { fg = colors.surface0 },
    SymbolUsageContent = { fg = colors.overlay2, bg = colors.surface0 },
    SymbolUsageRef = { fg = colors.blue, bg = colors.surface0 },
    SymbolUsageDef = { fg = colors.yellow, bg = colors.surface0 },
    SymbolUsageImpl = { fg = colors.mauve, bg = colors.surface0 },
    WhichKey = { fg = colors.yellow },
    WhichKeyDesc = { fg = colors.text },
    WhichKeySeparator = { fg = colors.pink },
    WhichKeyValue = { fg = colors.subtext1 },
  },
})

-- Apply colorscheme
vim.cmd("colorscheme catppuccin")

-- Change colorscheme dark/white mode
vim.api.nvim_create_user_command("BackgroundToggle", function()
  vim.o.background = (vim.o.background == "dark") and "light" or "dark"

  -- Unload/Reload plugins to apply palettes colors
  package.loaded["plugins.catppuccin_"] = nil
  package.loaded["catppuccin"] = nil
  require("plugins.catppuccin_")

end, { range = true })

-- Dap UI signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
