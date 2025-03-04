--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

require "helpers/globals"

-- Tabs {{{
opt.expandtab = true   -- Use spaces by default
opt.shiftround = true  -- Round indent
opt.shiftwidth = 2     -- the number of spaces inserted for each indentation
opt.tabstop = 2        -- 1 tab equal 2 spaces
opt.softtabstop = 2    -- When hitting <BS>, pretend like a tab is removed, even if spaces
opt.smartindent = true -- Turn on smart indentation. See in the docs for more info
opt.cmdheight = 0      -- Set cmdline height
-- }}}

-- Cursor {{{
opt.cursorline = true -- Highlight current cursorline
-- }}}

-- Clipboard {{{
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.fixeol = true             -- Turn off appending new line in the end of a file
-- }}}

-- Format {{{
opt.fileformat = "unix"    -- File line ending
opt.fileencoding = "utf-8" -- File encoding
-- }}}

-- Other {{{
opt.autoread = true      -- Watch for file changes
opt.laststatus = 2
opt.pumheight = 15       -- Limit height of popupmenu
opt.number = true        -- Enable line number
opt.wrap = true          -- Enable line wrap
opt.showcmd = false      -- Disable display of last command
opt.showmode = false     -- Disable -- INSERT --
opt.hidden = true        -- Enable modified buffers in background
opt.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150,n-v-c-sm:ver30"
--opt.completeopt = {}
opt.completeopt = { "menu", "menuone", "noselect" }
opt.termguicolors = true
vim.cmd("match EoLSpace /\\s\\+$/")
--vim.cmd("let &t_8f = '\\<Esc>[38;2;%lu;%lu;%lum'")
--vim.cmd("let &t_8b = '\\<Esc>[48;2;%lu;%lu;%lum'")
-- }}}

-- Search {{{
opt.ignorecase = true  -- Ignore case if all characters in lower case
opt.joinspaces = false -- Join multiple spaces in search
opt.smartcase = true   -- When there is a one capital letter search for exact match
opt.showmatch = true   -- Highlight search instances
opt.incsearch = true   -- Incremental search
-- }}}

-- Window {{{
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new vertical splits to right
-- }}}

-- Diagnostics {{{
vim.diagnostic.config({
  severity_sort = true,
  signs = true,
  virtual_text = {
    spacing = 4,
    prefix = "▎",
    format = function(diagnostic)
      return string.format(
        "%s (%s)",
        diagnostic.message,
        diagnostic.source
      )
    end,
  },
  float = {
    border = "none",
    format = function(diagnostic)
      return string.format(
        "%s (%s)",
        diagnostic.message,
        diagnostic.source
      )
    end,
  },
  virtual_box = true,
})

fn.sign_define(
  "DiagnosticSignError",
  {
    text = "",
    texthl = "DiagnosticSignError",
    numhl = "",
    linehl = "",
  }
)

fn.sign_define(
  "DiagnosticSignWarn",
  {
    text = "",
    texthl = "DiagnosticSignWarn",
    numhl = "",
    linehl = "",
  }
)

fn.sign_define(
  "DiagnosticSignInfo",
  {
    text = "",
    texthl = "DiagnosticSignInfo",
    numhl = "",
    linehl = "",
  }
)

fn.sign_define(
  "DiagnosticSignHint",
  {
    text = "",
    texthl = "DiagnosticSignHint",
    numhl = "",
    linehl = "",
  }
)
-- }}}

-- Default Plugins {{{
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end
-- }}}
