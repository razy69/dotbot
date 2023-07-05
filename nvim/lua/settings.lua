--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

require "helpers/globals"

-- Set associating between turned on plugins and filetype
cmd[[filetype plugin on]]

-- Disable comments on pressing Enter
cmd[[autocmd FileType * setlocal formatoptions-=cro]]

-- Tabs {{{
opt.expandtab = true                -- Use spaces by default
opt.shiftwidth = 2                  -- Set amount of space characters, when we press "<" or ">"
opt.tabstop = 2                     -- 1 tab equal 2 spaces
opt.softtabstop = 2                 -- When hitting <BS>, pretend like a tab is removed, even if spaces
opt.smartindent = true              -- Turn on smart indentation. See in the docs for more info
-- }}}

-- Mouse {{{
opt.mouse = v                       -- Middle-click paste with
-- }}}

-- Cursor {{{
opt.cursorline = true               -- Highlight current cursorline
-- }}}

-- Clipboard {{{
opt.clipboard = "unnamedplus"       -- Use system clipboard
opt.fixeol = true                   -- Turn off appending new line in the end of a file
-- }}}

-- Format {{{
opt.fileformat = "unix"
opt.fileencoding = "utf-8"
-- }}}

-- Other {{{
opt.number = true                  -- Enable line number
opt.wrap = true                    -- Enable line wrap
opt.showcmd = false                -- Disable display of last command
opt.showmode = false               -- Disable -- INSERT --
opt.guicursor = "i:ver25-iCursor"  -- Set vertical cursor in insert mode
opt.termguicolors = true           -- Enable 24-bit colour
-- }}}

-- Search {{{
opt.ignorecase = true              -- Ignore case if all characters in lower case
opt.joinspaces = false             -- Join multiple spaces in search
opt.smartcase = true               -- When there is a one capital letter search for exact match
opt.showmatch = true               -- Highlight search instances
opt.incsearch = true               -- Incremental search
-- }}}

-- Window {{{
opt.splitbelow = true              -- Put new windows below current
opt.splitright = true              -- Put new vertical splits to right
-- }}}

-- Wild Menu {{{
opt.wildmenu = true
opt.wildmode = "longest:full,full"
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