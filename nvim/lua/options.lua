--[[
  File: options.lua
  Description: Neovim options configuration.
]]

-- General
vim.cmd.syntax("manual")               -- Disable builtin syntax engine (treesitter handles highlighting;
-- autocmd in autocmd.lua re-enables syntax for filetypes without treesitter support)
vim.g.mapleader = " "                  -- Space as leader key
vim.g.maplocalleader = " "             -- Space as local leader key
vim.opt.termguicolors = true           -- Enable 24-bit RGB colors in the TUI

vim.g.autoformat = false               -- Disable auto-formatting on save (manual via :Format)
vim.g.editorconfig = false             -- Disable .editorconfig support (always use our global indent settings)
vim.g.markdown_recommended_style = 0   -- Disable markdown ftplugin overriding formatoptions
vim.g.no_gitrebase_maps = 1            -- Disable gitrebase ftplugin mappings (see runtime/ftplugin/gitrebase.vim)
vim.g.no_man_maps = 1                  -- Disable man ftplugin mappings (see runtime/ftplugin/man.vim)
vim.g.yaml_indent_multiline_scalar = 1 -- Indent multiline scalars in YAML
vim.opt.belloff = "all"                -- Silence all bell events
vim.opt.breakindent = true             -- Wrapped lines continue visually indented
vim.opt.completeopt = {}               -- Empty: blink.cmp handles completion UI
vim.opt.concealcursor = "n"            -- Conceal text only in normal mode (reveal in insert/visual)
vim.opt.conceallevel = 0               -- Show all text normally (no concealment)
vim.opt.confirm = true                 -- Prompt before closing unsaved buffers
vim.opt.diffopt = "filler,internal,closeoff,algorithm:histogram,context:5,linematch:60"
-- Use internal diff with histogram algorithm and line matching
vim.opt.errorbells = false -- No audible error bells
vim.opt.fillchars = { fold = " ", foldopen = "", foldsep = " ", foldclose = "", eob = " " }
-- Custom fold/end-of-buffer fill characters (Nerd Font icons)
vim.opt.fixeol = true           -- Ensure files end with a newline
vim.opt.formatoptions = "jqlnt" -- j: remove comment leader on join,
-- q: allow gq formatting, l: don't break long lines in insert,
-- n: recognize numbered lists, t: auto-wrap text
-- (c/r/o excluded: no auto-insert comment leader; BufWinEnter autocmd guards against ftplugins re-adding them)
-- vim.opt.hidden is true by default in Neovim
vim.opt.jumpoptions = "view"               -- Restore view (scroll position) when jumping
vim.opt.laststatus = 2                     -- Statusline on every window (neonvim.statusline renders it)
vim.opt.cmdheight = 1                      -- No cmdline row; ui2 overlays the statusline when the cmdline is active
vim.opt.lazyredraw = false                 -- Don't defer screen redraws (can cause issues with async plugins)
vim.opt.modeline = false                   -- Disable modelines for security
vim.opt.number = true                      -- Show line numbers
vim.opt.path:append("**")                  -- Search subdirectories with :find
vim.opt.path:remove("/usr/include")        -- Remove system includes from search path
vim.opt.pumblend = 10                      -- 10% pseudo-transparency for popup menu
vim.opt.pumheight = 10                     -- Limit popup menu to 10 visible items
vim.opt.report = 9999                      -- Suppress "N lines changed" messages
vim.opt.ruler = false                      -- Hide cursor position (statusline shows it)
vim.opt.scrolloff = 4                      -- Keep 4 lines visible above/below cursor
vim.opt.shada = {
  "'50",                                   -- Remember marks for the last 50 edited files
  "/50",                                   -- Save up to 50 search patterns
  ":50",                                   -- Save up to 50 command-line history entries
  "<50",                                   -- Save up to 50 lines for each register
  "@50",                                   -- Save up to 50 input-line history entries
  "f1",                                    -- Store file marks (uppercase marks persist across sessions)
  "h",                                     -- Disable hlsearch effect when loading shada
}
-- Per-project ShaDa file: marks, registers and histories scoped to each git
-- repo so jumping between projects doesn't pollute each other's state.
--
-- Must be set before Neovim reads the ShaDa file (startup step 16, after
-- plugin scripts are sourced), which is why it lives here — options.lua is
-- required from init.lua — rather than in a plugin/ config, where it worked
-- only for as long as that plugin happened to load eagerly.
--
-- Keyed by sha256 rather than base64: base64 is case-sensitive while APFS is
-- case-insensitive by default, so two cwds differing only in letter case
-- resolved to the same file.
do
  local root = vim.fs.root(0, ".git") or vim.uv.cwd()
  local file = vim.fs.joinpath(
    tostring(vim.fn.stdpath("data")),
    "project_shada",
    vim.fn.sha256(root)
  )
  vim.fn.mkdir(vim.fs.dirname(file), "p")
  vim.opt.shadafile = file
end

vim.opt.shortmess:append({                 -- Suppress messages:
  A = true,                                -- Skip swap file warnings
  C = true,                                -- Skip ins-completion scanning messages
  F = true,                                -- Skip file info when editing
  I = true,                                -- Skip intro message on startup
  S = false,                               -- Show search count (e.g. [1/5])
  W = true,                                -- Skip "written" messages
  a = true,                                -- Use short message abbreviations
  c = true,                                -- Skip ins-completion menu messages
  s = true,                                -- Skip "search hit BOTTOM/TOP" messages
})
vim.opt.showcmd = false                    -- Hide partial command display
vim.opt.showmode = false                   -- Hide mode indicator (statusline shows it)
vim.opt.showtabline = 2                    -- Always show tabline (neonvim.tabline renders it)
vim.opt.sidescrolloff = 8                  -- Keep 8 columns visible left/right of cursor
vim.opt.spelloptions:append "camel"        -- Treat CamelCase words as separate words for spell check
vim.opt.splitkeep = "screen"               -- Keep text on screen when opening splits
vim.opt.synmaxcol = 500                    -- Limit syntax highlighting to first 500 columns (performance)
vim.opt.title = true                       -- Set terminal title
vim.opt.titlestring = "%<%F%=%l/%L - nvim" -- Title format: filepath = line/total - nvim
-- vim.opt.ttyfast is always true in Neovim (no-op)
vim.opt.viewoptions = "cursor,folds"       -- Save/restore cursor position and folds in views
vim.opt.virtualedit = "block"              -- Allow cursor past end-of-line in visual block mode
vim.opt.visualbell = false                 -- No visual bell flash
vim.opt.winblend = 0                       -- Fully opaque floating windows
vim.opt.winminwidth = 5                    -- Minimum window width of 5 columns
vim.opt.wrap = true                        -- Enable soft line wrapping
vim.opt.winborder = "rounded"              -- Default border style for floating windows (Neovim 0.12+)

-- Timeout
vim.opt.timeout = true    -- Enable mapping timeout
vim.opt.timeoutlen = 300  -- Wait 300ms for mapped key sequences
vim.opt.ttimeout = true   -- Enable key code timeout
vim.opt.ttimeoutlen = 200 -- Wait 200ms for terminal key codes

-- Code Folding
-- Custom fold text with treesitter syntax highlighting
-- Credit: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/

--- Overlay higher-priority buffer extmark highlights on top of treesitter
--- captures. Plugins like blink.pairs (rainbow brackets) paint bracket
--- glyphs via extmarks with priority > 100; reading only treesitter
--- captures would render `}` in `@punctuation.bracket` grey while the
--- unfolded buffer shows it in the rainbow pair color — a visible
--- discrepancy between the folded summary and the live syntax colors.
--- Returns a buf_col -> hl_group map for the raw-byte window
--- [coloff, coloff + len) on row lnum — one query instead of one per byte.
---@param bufnr integer
---@param lnum integer 0-indexed row
---@param coloff integer First raw-byte column of the slice being rendered
---@param len integer Raw-byte length of the slice
---@return table<integer, string>
local function extmark_hl_range(bufnr, lnum, coloff, len)
  local out, best_priority = {}, {}
  -- `overlap = true` is too permissive: it returns marks whose end_col
  -- is exactly `coloff` as well, bleeding e.g. a `(` at [5,6) into `c` at
  -- col 6. The per-mark range clamp below drops any whose half-open
  -- [m_col, m_end_col) doesn't strictly intersect the window.
  local ok, marks = pcall(vim.api.nvim_buf_get_extmarks, bufnr, -1,
    { lnum, coloff }, { lnum, coloff + len },
    { details = true, overlap = true, type = "highlight" })
  if not ok or not marks then return out end

  for _, m in ipairs(marks) do
    local m_col = m[3]
    local d = m[4] or {}
    local m_end_col = d.end_col or (m_col + 1)
    local hl = d.hl_group
    -- Skip plugin decorations that aren't meaningful in a fold summary
    -- (squiggly diagnostics, transient cursor/search highlights).
    if hl
        and not hl:find("^Diagnostic") and not hl:find("^LspDiagnostic")
        and not hl:find("^Cursor") and not hl:find("^IncSearch")
        and not hl:find("^Search") then
      local priority = d.priority or 0
      for col = math.max(m_col, coloff), math.min(m_end_col - 1, coloff + len - 1) do
        if priority > (best_priority[col] or -1) then
          best_priority[col] = priority
          out[col] = hl
        end
      end
    end
  end
  return out
end

--- Build syntax-highlighted virtual text for a single line of a fold.
--- Resolves each byte's highlight by combining treesitter captures (base
--- layer) with higher-priority buffer extmark highlights (overlay
--- layer), matching what Neovim actually paints at that position.
---
--- IMPORTANT: `s` must be the raw line (no tab expansion). Treesitter
--- and extmark APIs return *raw byte* columns; expanding tabs to spaces
--- in `s` before indexing shifts every character by (tabstop-1) per
--- preceding tab, which puts each token's highlight onto the character
--- to its left. Tabs are expanded when chunks are emitted instead, so
--- display width stays correct without breaking the hl map.
---@param result table[] Accumulator: array of {text, highlight} pairs
---@param s string The raw line text (must NOT have tabs pre-expanded)
---@param lnum integer 0-indexed line number in the buffer
---@param coloff? integer Raw-byte column offset (default 0) — non-zero
---   when `s` is a trimmed slice of the real line, used to map back
---   into buffer cols
local function fold_virt_text(result, s, lnum, coloff)
  coloff = coloff or 0
  local bufnr = vim.api.nvim_get_current_buf()
  local tabwidth = vim.bo[bufnr].tabstop

  -- Base layer: treesitter captures. iter_captures is far cheaper than
  -- a per-char query and orders matches such that more-specific captures
  -- come last, so overwriting in hl_map yields the same resolution
  -- Neovim's highlighter uses.
  ---@type table<integer, string>
  local hl_map = {}
  pcall(function()
    local parser = vim.treesitter.get_parser(bufnr)
    if not parser then return end
    parser:parse()
    parser:for_each_tree(function(tstree, ltree)
      local lang = ltree:lang()
      local query = vim.treesitter.query.get(lang, "highlights")
      if not query then
        return
      end
      for id, node in query:iter_captures(tstree:root(), bufnr, lnum, lnum + 1) do
        local sr, sc, er, ec = node:range()
        if sr <= lnum and er >= lnum then
          local start_col = sr < lnum and 1 or (sc - coloff + 1)
          local end_col = er > lnum and #s or (ec - coloff)
          -- Use the base capture name — Neovim registers per-language
          -- variants like `@keyword.conditional.go` as *empty* hl groups
          -- rather than links to the base (at least in 0.12). Passing the
          -- suffixed name into a foldtext chunk renders with no
          -- attributes (only the inherited Folded fg is applied), which
          -- looked like "the last character of each token lost its
          -- colour". The base `@keyword.conditional` carries the real
          -- link chain and renders correctly.
          local hl = "@" .. query.captures[id]
          for i = math.max(1, start_col), math.min(#s, end_col) do
            hl_map[i] = hl
          end
        end
      end
    end)
  end)

  -- Overlay layer: buffer extmark highlights. Per-byte lookup — fine
  -- because we only run this for short fold anchor strings. Any extmark
  -- with priority > 100 takes precedence over the treesitter capture,
  -- mirroring Neovim's highlight-stacking rules.
  local em_hl = extmark_hl_range(bufnr, lnum, coloff, #s)
  for i = 1, #s do
    local hl = em_hl[coloff + i - 1]
    if hl then
      hl_map[i] = hl
    end
  end

  -- Emit chunks: walk bytes, merging runs with the same hl. A tab byte
  -- is expanded to `tabwidth` spaces at emit time so the fold summary
  -- lines up visually without breaking the byte-indexed hl map.
  local text = ""
  ---@type string?
  local hl = nil
  for i = 1, #s do
    local new_hl = hl_map[i]
    local ch = s:sub(i, i)
    if ch == "\t" then
      ch = string.rep(" ", tabwidth)
    end
    if new_hl ~= hl then
      if #text > 0 then
        table.insert(result, { text, hl })
      end
      text = ch
      hl = new_hl
    else
      text = text .. ch
    end
  end
  if #text > 0 then
    table.insert(result, { text, hl })
  end
end

--- Global fold text function referenced by foldtext option.
--- Returns syntax-highlighted text for the first line of the fold,
--- followed by the last line's trailing closing punctuation (stripped
--- of leading whitespace) so the anchor reads like a single-line
--- summary — e.g. `func Foo() { ... }` instead of `func Foo() { ...`
--- with a dangling `}` below. Then a line count indicator.
---@return table[] Array of {text, highlight} pairs for statusline-style rendering
_G.get_fold_text = function()
  -- Pass the raw line (tabs intact) — fold_virt_text indexes by raw byte
  -- column to match treesitter captures, and expands tabs at chunk
  -- emission so the display width is still correct.
  local start = vim.fn.getline(vim.v.foldstart)
  local result = {}

  fold_virt_text(result, start, vim.v.foldstart - 1)

  -- Remember the hl of the last opening bracket on the anchor line. The
  -- matching closing bracket on the hidden last line won't have any
  -- plugin-provided extmark (blink.pairs places its rainbow-pair
  -- highlights via a decoration_provider that only fires for visible
  -- lines), so our per-char extmark lookup would miss the rainbow color
  -- there. Carrying the opener's hl forward lets us paint the close
  -- with the same color the user sees when unfolded.
  local opener_hl = nil
  for _, chunk in ipairs(result) do
    if chunk[1]:find("[{(%[]") then
      opener_hl = chunk[2]
    end
  end

  table.insert(result, { " ... ", "Delimiter" })

  -- Append the last line's content with full treesitter + extmark
  -- resolution. `coloff` maps the trimmed string back into raw buffer
  -- byte columns so the lookups query the right positions. Tabs stay
  -- in the string — fold_virt_text expands them at emit time.
  if vim.v.foldend > vim.v.foldstart then
    local last_raw = vim.fn.getline(vim.v.foldend)
    local last_trim = last_raw:gsub("^%s+", "")
    if last_trim ~= "" then
      local coloff = #last_raw - #last_trim
      local prev_len = #result
      fold_virt_text(result, last_trim, vim.v.foldend - 1, coloff)

      -- Re-color the first closing bracket chunk on the last line so it
      -- matches the opener. Only the first match is rewritten — any
      -- further brackets (e.g. `})` pair where a function call follows
      -- the block close) keep their own lookup.
      if opener_hl then
        for i = prev_len + 1, #result do
          if result[i][1]:find("[})%]]") then
            result[i] = { result[i][1], opener_hl }
            break
          end
        end
      end
    end
  end

  table.insert(result, { "  󰉸 " .. (vim.v.foldend - vim.v.foldstart) .. " line(s)", "Delimiter" })

  return result
end

vim.opt.foldcolumn = "0"                             -- Hide fold column (statuscolumn plugin handles fold indicators)
vim.opt.foldenable = true                            -- Enable folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for fold boundaries
vim.opt.foldlevelstart = 99                          -- Start with all folds open when opening a file
vim.opt.foldmethod = "expr"                          -- Use expression-based folding (treesitter)
vim.opt.foldopen = "insert,mark,search,tag"          -- Auto-open folds for these actions
vim.opt.foldtext = "v:lua.get_fold_text()"           -- Custom fold text with treesitter highlights

-- Indentation
-- vim.opt.autoindent is true by default in Neovim
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.shiftround = true  -- Round indent to multiple of shiftwidth
vim.opt.shiftwidth = 2     -- Number of spaces for each indent level
vim.opt.smartindent = true -- Auto-indent after {, keywords, etc.
vim.opt.smarttab = false   -- <Tab> at start of line inserts shiftwidth spaces
vim.opt.softtabstop = 2    -- Number of spaces <Tab> counts for while editing
vim.opt.tabstop = 2        -- Display width of a <Tab> character

-- Cursor
vim.opt.cursorline = true -- Highlight the line containing the cursor
vim.opt.guicursor = "n-v-c-sm:block-Cursor-blinkon0,i-ci:ver30-Cursor,r:hor50-Cursor"
-- Block cursor (no blink) in normal/visual/command,
-- thin vertical bar in insert, horizontal bar in replace
vim.opt.mouse = "a" -- Enable mouse in all modes

-- Clipboard
vim.opt.clipboard:append { "unnamed", "unnamedplus" } -- Sync with system clipboard

-- Disable unused builtin providers (faster startup)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Use ripgrep for :grep if available
if vim.fn.executable("rg") then
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
end

-- File
vim.opt.autoread = false                                 -- Don't auto-reload files changed outside (checktime autocmd handles this)
vim.opt.autowrite = false                                -- Don't auto-save before :make, :next, etc.
vim.opt.backup = false                                   -- No backup files
-- vim.opt.encoding is always utf-8 in Neovim
vim.opt.fileencoding = "utf-8"                           -- Default file encoding
vim.opt.fileformats = { "unix", "dos", "mac" }           -- Line ending detection order
vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undodir") -- Persistent undo directory
vim.opt.undofile = true                                  -- Enable persistent undo across sessions
vim.opt.undolevels = 1000                                -- Maximum number of undo steps
vim.opt.updatetime = 200                                 -- CursorHold delay in ms (also affects swap file writes)

-- Wildmenu
vim.opt.wildmenu = false -- Disable wildmenu (fzf-lua handles file/command completion)

-- Search
vim.opt.gdefault = true      -- Apply substitutions globally by default (:s/foo/bar/ acts like :s/foo/bar/g)
vim.opt.ignorecase = true    -- Case-insensitive search by default
vim.opt.inccommand = "split" -- Show live substitution preview in a split
vim.opt.previewheight = 20   -- Preview split can grow to this many lines before scrolling
-- vim.opt.incsearch is true by default in Neovim
vim.opt.joinspaces = false   -- Don't insert double spaces after periods when joining lines
vim.opt.showmatch = true     -- Briefly jump to matching bracket when inserting one
vim.opt.smartcase = true     -- Case-sensitive search when pattern contains uppercase

-- Window splitting
vim.opt.splitbelow = true -- Horizontal splits open below
vim.opt.splitright = true -- Vertical splits open to the right

-- Session
vim.opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "winpos", "winsize", "resize", "terminal" }

-- Disable builtin plugins (using alternatives: neo-tree for file browsing, etc.)
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_netrwSettings = 0
vim.g.loaded_netrwFileHandlers = 0

vim.g.loaded_matchit = 0    -- Disabled: flash.nvim provides enhanced matching
vim.g.loaded_matchparen = 0 -- Disabled: blink.pairs handles paren highlighting
vim.g.loaded_logiPat = 0    -- Unused: logical pattern search plugin
vim.g.loaded_rrhelper = 0   -- Unused: remote plugin helper

-- Diagnostic signs only (full diagnostic config lives in plugin/03-lsp.lua)
vim.diagnostic.config({
  signs = {
    [vim.diagnostic.severity.ERROR] = { text = "", texthl = "DiagnosticSignError" },
    [vim.diagnostic.severity.WARN] = { text = "", texthl = "DiagnosticSignWarn" },
    [vim.diagnostic.severity.INFO] = { text = "", texthl = "DiagnosticSignInfo" },
    [vim.diagnostic.severity.HINT] = { text = "", texthl = "DiagnosticSignHint" },
  },
})
