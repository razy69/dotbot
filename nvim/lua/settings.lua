--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

require("globals")

-- Configure timeout for which-key panel
opt.ttimeout = true
opt.ttimeoutlen = 10 -- Key code timeout
opt.timeout = true
opt.timeoutlen = 300 -- Mapping timeout

-- Code Folding
opt.foldcolumn = "0"
opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldtext = ""
opt.foldexpr = ""
g.foldmethod = ""

-- Tabs
opt.autoindent = true
opt.expandtab = true   -- Use spaces by default
opt.shiftround = true  -- Round indent
opt.shiftwidth = 2     -- the number of spaces inserted for each indentation
opt.tabstop = 2        -- 1 tab equal 2 spaces
opt.softtabstop = 2    -- When hitting <BS>, pretend like a tab is removed, even if spaces
opt.smartindent = true -- Turn on smart indentation. See in the docs for more info
opt.smarttab = true    -- Handle tabs more intelligently

-- Cursor
opt.cursorline = true -- Highlight current cursorline
opt.guicursor = "n-v-c-sm:block-Cursor-blinkon0,i-ci:ver30-Cursor,r:hor50-Cursor"
opt.mousemoveevent = true
opt.mouse = "a"
vim.cmd("set guioptions-=T")

-- Clipboard
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Other
opt.completeopt = { "menu", "menuone", "noselect" }
vim.cmd("match EoLSpace /\\s\\+$/")
opt.fixeol = true -- Turn off appending new line in the end of a file
opt.fillchars:append("eob: ")
opt.laststatus = 0
opt.path:remove("/usr/include")
opt.path:append("**")
opt.splitkeep = "topline"
opt.shortmess = "IOocWTtFxnflCi"
opt.showtabline = 0
opt.diffopt:append("linematch:60")
opt.lazyredraw = false
opt.winblend = 0
opt.cmdheight = 0    -- Set cmdline height
opt.pumheight = 15   -- Limit height of popupmenu
opt.pumblend = 0
opt.number = true    -- Enable line number
opt.wrap = true      -- Enable line wrap
opt.showcmd = false  -- Disable display of last command
opt.showmode = false -- Disable -- INSERT --
opt.hidden = true    -- Enable modified buffers in background
opt.modeline = false
opt.ruler = false
opt.ttyfast = true
opt.errorbells = false
opt.visualbell = false
opt.title = true
opt.titlestring = "%<%F%=%l/%L - nvim"
opt.termguicolors = true
opt.confirm = true
opt.spelloptions:append "camel"
opt.scrolloff = 10
opt.backspace = "indent,eol,start"
opt.conceallevel = 0
opt.concealcursor = "n"
opt.breakindent = true
g.no_gitrebase_maps = 1 -- See share/nvim/runtime/ftplugin/gitrebase.vim
g.no_man_maps = 1       -- See share/nvim/runtime/ftplugin/man.vim
g.editorconfig = false
g.autoformat = false
g.markdown_recommended_style = 0
g.yaml_indent_multiline_scalar = 1

-- Disable python/perl/ruby/node providers
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0

-- RipGrep options
if fn.executable("rg") then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- File
opt.fileformats = { "unix", "dos", "mac" }
opt.fileencoding = "utf-8" -- File encoding
opt.encoding = "utf-8"
opt.autowrite = false
opt.autoread = false
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 100
opt.shada = ""
g.bigfile_size = 1024 * 1024 * 5 -- 5 MB

-- Wildmenu
opt.wildmenu = true
opt.wildmode = "list:longest"
opt.wildignore =
"**/.git/*,**/node_modules/*,.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor,*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite"
opt.wildoptions = { "pum" }

-- Search
opt.ignorecase = true  -- Ignore case if all characters in lower case
opt.joinspaces = false -- Join multiple spaces in search
opt.smartcase = true   -- When there is a one capital letter search for exact match
opt.showmatch = true   -- Highlight search instances
opt.incsearch = true   -- Incremental search
opt.inccommand = "split"
opt.gdefault = true

-- Window
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new vertical splits to right

-- Diagnostics
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

-- Default Plugins
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
