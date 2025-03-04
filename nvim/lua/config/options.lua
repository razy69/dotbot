--[[
  File: settings.lua
  Description: Base settings for neovim
]]

-- Configure timeout for which-key panel
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10 -- Key code timeout
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- Mapping timeout

-- Code Folding
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldtext = ""
vim.opt.foldexpr = ""
vim.g.foldmethod = ""

-- Tabs
vim.opt.autoindent = true
vim.opt.expandtab = true   -- Use spaces by default
vim.opt.shiftround = true  -- Round indent
vim.opt.shiftwidth = 2     -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2        -- 1 tab equal 2 spaces
vim.opt.softtabstop = 2    -- When hitting <BS>, pretend like a tab is removed, even if spaces
vim.opt.smartindent = true -- Turn on smart indentation. See in the docs for more info
vim.opt.smarttab = true    -- Handle tabs more intelligently

-- Cursor
vim.opt.cursorline = true -- Highlight current cursorline
vim.opt.guicursor = "n-v-c-sm:block-Cursor-blinkon0,i-ci:ver30-Cursor,r:hor50-Cursor"
vim.opt.mousemoveevent = true
vim.opt.mouse = "a"

-- Clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Other
vim.cmd("match EoLSpace /\\s\\+$/")
vim.opt.signcolumn = "yes"
vim.opt.completeopt = {}
vim.opt.fixeol = true -- Turn off appending new line in the end of a file
vim.opt.fillchars:append("eob: ")
vim.opt.laststatus = 0
vim.opt.path:remove("/usr/include")
vim.opt.path:append("**")
vim.opt.splitkeep = "topline"
vim.opt.shortmess = "IOocWTtFxnflCi"
vim.opt.showtabline = 0
vim.opt.diffopt:append("linematch:60")
vim.opt.lazyredraw = false
vim.opt.winblend = 0
vim.opt.cmdheight = 0    -- Set cmdline height
vim.opt.pumheight = 15   -- Limit height of popupmenu
vim.opt.pumblend = 0
vim.opt.number = true    -- Enable line number
vim.opt.wrap = true      -- Enable line wrap
vim.opt.showcmd = false  -- Disable display of last command
vim.opt.showmode = false -- Disable -- INSERT --
vim.opt.hidden = true    -- Enable modified buffers in background
vim.opt.modeline = false
vim.opt.ruler = false
vim.opt.ttyfast = true
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.title = true
vim.opt.titlestring = "%<%F%=%l/%L - nvim"
vim.opt.termguicolors = true
vim.opt.confirm = true
vim.opt.spelloptions:append "camel"
vim.opt.scrolloff = 10
vim.opt.backspace = "indent,eol,start"
vim.opt.conceallevel = 0
vim.opt.concealcursor = "n"
vim.opt.breakindent = true
vim.g.no_gitrebase_maps = 1 -- See share/nvim/runtime/ftplugin/gitrebase.vim
vim.g.no_man_maps = 1       -- See share/nvim/runtime/ftplugin/man.vim
vim.g.editorconfig = false
vim.g.autoformat = false
vim.g.markdown_recommended_style = 0
vim.g.yaml_indent_multiline_scalar = 1

-- Disable python/perl/ruby/node providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- RipGrep options
if vim.fn.executable("rg") then
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- File
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.fileencoding = "utf-8" -- File encoding
vim.opt.encoding = "utf-8"
vim.opt.autowrite = false
vim.opt.autoread = false
vim.opt.undolevels = 1000
vim.opt.updatetime = 100
vim.opt.shada = ""
vim.g.bigfile_size = 1024 * 1024 * 5 -- 5 MB

-- Wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest"
vim.opt.wildignore =
"**/.git/*,**/node_modules/*,.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor,*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite"
vim.opt.wildoptions = { "pum" }

-- Search
vim.opt.ignorecase = true  -- Ignore case if all characters in lower case
vim.opt.joinspaces = false -- Join multiple spaces in search
vim.opt.smartcase = true   -- When there is a one capital letter search for exact match
vim.opt.showmatch = true   -- Highlight search instances
vim.opt.incsearch = true   -- Incremental search
vim.opt.inccommand = "split"
vim.opt.gdefault = true

-- Window
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new vertical splits to right

-- Diagnostics
vim.diagnostic.config({
  severity_sort = true,
  signs = true,
  underline = false,
  update_in_insert = false,
  virtual_box = true,
  virtual_text = {
    spacing = 4,
    prefix = "▎",
    source = "if_many",
    format = function(diagnostic)
      return string.format(
        "%s (%s: %s)",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code
      )
    end,
  },
  float = {
    border = "none",
    format = function(diagnostic)
      return string.format(
        "%s (%s: %s)",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code
      )
    end,
  },
})
vim.fn.sign_define(
  "DiagnosticSignError",
  {
    text = "",
    texthl = "DiagnosticSignError",
    numhl = "",
    linehl = "",
  }
)
vim.fn.sign_define(
  "DiagnosticSignWarn",
  {
    text = "",
    texthl = "DiagnosticSignWarn",
    numhl = "",
    linehl = "",
  }
)
vim.fn.sign_define(
  "DiagnosticSignInfo",
  {
    text = "",
    texthl = "DiagnosticSignInfo",
    numhl = "",
    linehl = "",
  }
)
vim.fn.sign_define(
  "DiagnosticSignHint",
  {
    text = "",
    texthl = "DiagnosticSignHint",
    numhl = "",
    linehl = "",
  }
)
