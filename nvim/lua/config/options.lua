--[[
  File: options.lua
  Description: Options configuration.
]]

-- General
vim.cmd.syntax("manual") -- Disable builtin syntax (use treesitter instead, but autocmd for FileType not supported by treesitter)

vim.g.autoformat = false
vim.g.editorconfig = false
vim.g.markdown_recommended_style = 0
vim.g.no_gitrebase_maps = 1 -- See share/nvim/runtime/ftplugin/gitrebase.vim
vim.g.no_man_maps = 1       -- See share/nvim/runtime/ftplugin/man.vim
vim.g.yaml_indent_multiline_scalar = 1
vim.opt.backspace = "indent,eol,start"
vim.opt.belloff = "all" -- Do not ring the bell for any event
vim.opt.breakindent = true
vim.opt.cmdheight = 0   -- Set cmdline height
vim.opt.completeopt = {}
vim.opt.concealcursor = "n"
vim.opt.conceallevel = 0
vim.opt.confirm = true
vim.opt.diffopt = "filler,internal,closeoff,algorithm:histogram,context:5,linematch:60"
vim.opt.errorbells = false
vim.opt.fillchars = { fold = " ", foldopen = "", foldsep = " ", foldclose = "", eob = " " }
vim.opt.fixeol = true   -- Turn off appending new line in the end of a file
vim.opt.formatoptions = "jcroqlnt"
vim.opt.gdefault = true -- Use g flag for ":substitute"
vim.opt.hidden = true   -- Enable modified buffers in background
vim.opt.jumpoptions = "view"
vim.opt.laststatus = 0
vim.opt.lazyredraw = false
vim.opt.modeline = false
vim.opt.number = true -- Enable line number
vim.opt.path:append("**")
vim.opt.path:remove("/usr/include")
vim.opt.pumblend = 10  -- Enables pseudo-transparency for the popup-menu (0 for fully opaque window)
vim.opt.pumheight = 10 -- Limit height of popupmenu
vim.opt.report = 9999  -- Don't report number of changed lines.
vim.opt.ruler = false
vim.opt.scrolloff = 4
vim.opt.shada = {
  '"50', -- Max number of lines saved for each register.
  "'50", -- Remember marks for the last 10 edited files.
  "/50", -- Max number of items in the search pattern.
  ":50", -- Max number of items in the command-line history.
  "<50", -- Max number of lines saved for each register.
  "@50", -- Max number of items in the input-line history.
  "f1",  -- Save all file marks
  "h",   -- Disable the effect of hlsearch when loading the shada file.
}
vim.opt.shortmess:append({ -- Don't show messages:
  A = true,                -- When a swap file is found.
  C = true,                -- When scanning for "ins-completion" items.
  F = true,                -- File info when editing a file.
  I = true,                -- Skip intro message.
  S = true,                -- Search messages, using nvim-hlslens instead.
  W = true,                -- When writing a file.
  a = true,                -- Use abbreviations
  c = true,                -- 'ins-completion-menu' messages.
  s = true,                -- Search hit BOTTOM/TOP messages.
})
vim.opt.showcmd = false    -- Disable display of last command
vim.opt.showmode = false   -- Disable -- INSERT --
vim.opt.showtabline = 0
vim.opt.sidescrolloff = 8
vim.opt.spelloptions:append "camel"
vim.opt.splitkeep = "screen"
vim.opt.synmaxcol = 500 -- limits how much of a long horizontal line is highlighted by nvim’s syntax engine
vim.opt.title = true
vim.opt.titlestring = "%<%F%=%l/%L - nvim"
vim.opt.ttyfast = true
vim.opt.viewoptions = "cursor,folds" -- Save cursor position and folds.
vim.opt.virtualedit = "block"        -- Allow cursor to move where there is no text in visual block mode
vim.opt.visualbell = false
vim.opt.winblend = 0                 -- Enables pseudo-transparency for a floating window (0 for fully opaque window)
vim.opt.winminwidth = 5
vim.opt.wrap = true                  -- Enable line wrap

-- Timeout
vim.opt.timeout = true
vim.opt.timeoutlen = 300  -- Mapping timeout
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200 -- Key code timeout

-- Code Folding
-- from: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, s, lnum, coloff)
  if not coloff then
    coloff = 0
  end

  local text = ""
  local hl
  for i = 1, #s do
    local char = s:sub(i, i)
    local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
    local _hl = hls[#hls]

    if _hl then
      local new_hl = "@" .. _hl.capture
      if new_hl ~= hl then
        table.insert(result, { text, hl })
        text = ""
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end

  table.insert(result, { text, hl })
end

_G.get_fold_text = function()
  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local result = {}

  fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })
  table.insert(result, { "  󰉸 " .. (vim.v.foldend - vim.v.foldstart) .. " line(s)", "Delimiter" })

  return result
end

vim.opt.foldcolumn = "0"
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 999
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldopen = "insert,mark,search,tag"
vim.opt.foldtext = "v:lua.get_fold_text()"

-- Tabs
vim.opt.autoindent = true
vim.opt.expandtab = true   -- Use spaces by default
vim.opt.shiftround = true  -- Round indent
vim.opt.shiftwidth = 2     -- the number of spaces inserted for each indentation
vim.opt.smartindent = true -- Turn on smart indentation. See in the docs for more info
vim.opt.smarttab = true    -- Handle tabs more intelligently
vim.opt.softtabstop = 2    -- When hitting <BS>, pretend like a tab is removed, even if spaces
vim.opt.tabstop = 2        -- 1 tab equal 2 spaces

-- Cursor
vim.opt.cursorline = true -- Highlight current cursorline
vim.opt.guicursor = "n-v-c-sm:block-Cursor-blinkon0,i-ci:ver30-Cursor,r:hor50-Cursor"
vim.opt.mouse = "a"
vim.opt.mousemoveevent = true

-- Clipboard
vim.opt.clipboard:append { "unnamed", "unnamedplus" }

-- Disable builtin providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- RipGrep options
if vim.fn.executable("rg") then
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
end

-- File
vim.opt.autoread = false
vim.opt.autowrite = false
vim.opt.backup = false
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"                           -- File encoding
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undodir") -- Set custom undo directory
vim.opt.undofile = true                                  -- Enable persistent undo
vim.opt.undolevels = 1000
vim.opt.updatetime = 100

-- Wildmenu
vim.opt.wildmenu = false

-- Search
vim.opt.gdefault = true
vim.opt.ignorecase = true  -- Ignore case if all characters in lower case
vim.opt.inccommand = "split"
vim.opt.incsearch = true   -- Incremental search
vim.opt.joinspaces = false -- Join multiple spaces in search
vim.opt.showmatch = true   -- Highlight search instances
vim.opt.smartcase = true   -- When there is a one capital letter search for exact match

-- Window
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new vertical splits to right

-- Session
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "winpos", "winsize", "resize", "terminal" }

vim.diagnostic.config({
  signs = {
    active = true,
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
