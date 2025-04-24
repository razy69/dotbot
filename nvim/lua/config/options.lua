--[[
  File: options.lua
  Description: Nvim options configuration
]]

-- General
vim.cmd("match EoLSpace /\\s\\+$/")
vim.cmd.syntax("manual") -- Disable builtin syntax (use treesitter instead, but autocmd for FileType not supported by treesitter)
vim.opt.synmaxcol = 500  -- limits how much of a long horizontal line is highlighted by nvim’s syntax engine
vim.opt.fillchars = { fold = " ", foldopen = "", foldsep = " ", foldclose = "", eob = " " }
vim.opt.fixeol = true    -- Turn off appending new line in the end of a file
vim.opt.laststatus = 0
vim.opt.path:remove("/usr/include")
vim.opt.path:append("**")
vim.opt.splitkeep = "screen"
vim.opt.showtabline = 0
vim.opt.diffopt:append("linematch:60")
vim.opt.lazyredraw = false
vim.opt.winblend = 0          -- Enables pseudo-transparency for a floating window (0 for fully opaque window)
vim.opt.cmdheight = 0         -- Set cmdline height
vim.opt.pumheight = 10        -- Limit height of popupmenu
vim.opt.pumblend = 10         -- Enables pseudo-transparency for the popup-menu (0 for fully opaque window)
vim.opt.number = true         -- Enable line number
vim.opt.wrap = true           -- Enable line wrap
vim.opt.showcmd = false       -- Disable display of last command
vim.opt.showmode = false      -- Disable -- INSERT --
vim.opt.hidden = true         -- Enable modified buffers in background
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
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
vim.opt.scrolloff = 4
vim.opt.backspace = "indent,eol,start"
vim.opt.conceallevel = 0
vim.opt.concealcursor = "n"
vim.opt.breakindent = true
vim.opt.sidescrolloff = 8
vim.opt.jumpoptions = "view"
vim.opt.formatoptions = "jcroqlnt"
vim.opt.winminwidth = 5
vim.g.no_gitrebase_maps = 1 -- See share/nvim/runtime/ftplugin/gitrebase.vim
vim.g.no_man_maps = 1       -- See share/nvim/runtime/ftplugin/man.vim
vim.g.editorconfig = false
vim.g.autoformat = false
vim.g.markdown_recommended_style = 0
vim.g.yaml_indent_multiline_scalar = 1

-- Timeout
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200 -- Key code timeout
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- Mapping timeout

-- Code Folding
_G.get_fold_text = function()
  return vim.fn.getline(vim.v.foldstart) ..
      " ... " ..
      vim.fn.getline(vim.v.foldend):gsub("^%s*", "") .. "  󰉸 " .. (vim.v.foldend - vim.v.foldstart + 1) .. " lines"
end
vim.opt.foldtext = "v:lua.get_fold_text()"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0"
vim.opt.foldenable = true

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
vim.opt.clipboard:append { "unnamed", "unnamedplus" }

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

-- Wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
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

-- Session
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "winpos", "winsize", "resize", "terminal" }

-- Diagnostics
vim.diagnostic.config({
  severity_sort = true,
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
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})
