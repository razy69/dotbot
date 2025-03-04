--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

require "helpers/globals"

-- Disable comments on pressing Enter
cmd[[autocmd FileType * setlocal formatoptions-=cro]]

-- Tabs {{{
cmd[[autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4]]
opt.expandtab = true                   -- Use spaces by default
opt.shiftround = true                  -- Round indent
opt.shiftwidth = 2                     -- the number of spaces inserted for each indentation
opt.tabstop = 2                        -- 1 tab equal 2 spaces
opt.softtabstop = 2                    -- When hitting <BS>, pretend like a tab is removed, even if spaces
opt.smartindent = true                 -- Turn on smart indentation. See in the docs for more info
-- }}}

-- Cursor {{{
opt.cursorline = true                  -- Highlight current cursorline
-- }}}

-- Clipboard {{{
opt.clipboard = "unnamedplus"          -- Use system clipboard
opt.fixeol = true                      -- Turn off appending new line in the end of a file
-- }}}

-- Format {{{
opt.fileformat = "unix"                -- File line ending
opt.fileencoding = "utf-8"             -- File encoding
-- }}}

-- Other {{{
opt.number = true                      -- Enable line number
opt.wrap = true                        -- Enable line wrap
opt.showcmd = false                    -- Disable display of last command
opt.showmode = false                   -- Disable -- INSERT --
opt.guicursor = "i-v-n:ver25-iCursor"  -- Set vertical cursor in insert mode
opt.termguicolors = true               -- Enable 24-bit colour
opt.hidden = true                      -- Enable modified buffers in background
-- }}}

-- Search {{{
opt.ignorecase = true                  -- Ignore case if all characters in lower case
opt.joinspaces = false                 -- Join multiple spaces in search
opt.smartcase = true                   -- When there is a one capital letter search for exact match
opt.showmatch = true                   -- Highlight search instances
opt.incsearch = true                   -- Incremental search
-- }}}

-- Window {{{
opt.splitbelow = true                  -- Put new windows below current
opt.splitright = true                  -- Put new vertical splits to right
-- }}}

-- Diagnostics {{{
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
