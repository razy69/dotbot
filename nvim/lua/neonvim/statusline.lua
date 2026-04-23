---@brief Lightweight statusline, replaces lualine. One global function
--- rendered per-window via `vim.o.statusline = "%!v:lua.statusline()"`.
--- Powerline-style transitions (\u{E0B0}/\u{E0B2}) between six sections,
--- matching lualine's default look. Nerd-font glyphs are written via
--- `\u{...}` escapes so they survive pass-through through tools that
--- might otherwise strip high-plane UTF-8 bytes.

local M              = {}

-- === Glyphs ============================================================

local SEP_R          = "\u{E0B0}" -- section separator, right-pointing solid triangle (left-side)
local SEP_L          = "\u{E0B2}" -- section separator, left-pointing solid triangle (right-side)
local COMP_SEP_R     = "\u{E0B1}" -- component separator, thin right-pointing (inside b)
local COMP_SEP_L     = "\u{E0B3}" -- component separator, thin left-pointing (inside x)
local ICON_BRANCH    = "\u{E0A0}" --
local ICON_DIAG_ERR  = "\u{EA76}" --  codicon:error
local ICON_DIAG_WARN = "\u{EA6C}" --  codicon:warning
local ICON_DIAG_INFO = "\u{EA74}" --  codicon:info
local ICON_DIAG_HINT = "\u{EA6B}" --  codicon:lightbulb
local ICON_LSP       = "\u{F013}" --  fa-cog
local ICON_LSP_OK    = "\u{2713}" -- ✓
local ICON_PROGRESS  = "\u{F09F}" --  (progression %)
local ICON_LOCATION  = "\u{F039}" --  powerline line-number glyph
local ICON_FF_UNIX   = "\u{F17C}" --  fa-linux
local ICON_FF_DOS    = "\u{F17A}" --  fa-windows
local ICON_FF_MAC    = "\u{F179}" --  fa-apple
local ICON_ARROW     = "\u{F1841}" -- 󱡁 nf-md-bookmark_multiple (matches arrow.nvim)

-- Spinner frames for LSP progress (same set as lualine's default:
-- U+280B, U+2819, U+2839, U+2838, U+283C, U+2834, U+2826, U+2827, U+2807, U+280F).
local spinner_frames = {
  "\u{280B}", "\u{2819}", "\u{2839}", "\u{2838}", "\u{283C}",
  "\u{2834}", "\u{2826}", "\u{2827}", "\u{2807}", "\u{280F}",
}
local spinner_idx    = 1

-- Mode -> { label, base highlight name }. The mode codes come from
-- :h mode() — we cover every documented value so the label never falls
-- back to a raw `CV` / `niI` code in the status pill.
local mode_info      = {
  ["n"]     = { "NORMAL", "StModeNormal" },
  ["no"]    = { "O-PEND", "StModeNormal" },
  ["nov"]   = { "O-PEND", "StModeNormal" },
  ["noV"]   = { "O-PEND", "StModeNormal" },
  ["no\22"] = { "O-PEND", "StModeNormal" },
  ["niI"]   = { "NORMAL", "StModeNormal" },
  ["niR"]   = { "NORMAL", "StModeNormal" },
  ["niV"]   = { "NORMAL", "StModeNormal" },
  ["nt"]    = { "NORMAL", "StModeNormal" },
  ["ntT"]   = { "NORMAL", "StModeNormal" },
  ["v"]     = { "VISUAL", "StModeVisual" },
  ["vs"]    = { "VISUAL", "StModeVisual" },
  ["V"]     = { "V-LINE", "StModeVisual" },
  ["Vs"]    = { "V-LINE", "StModeVisual" },
  ["\22"]   = { "V-BLOCK", "StModeVisual" },
  ["\22s"]  = { "V-BLOCK", "StModeVisual" },
  ["s"]     = { "SELECT", "StModeVisual" },
  ["S"]     = { "S-LINE", "StModeVisual" },
  ["\19"]   = { "S-BLOCK", "StModeVisual" },
  ["i"]     = { "INSERT", "StModeInsert" },
  ["ic"]    = { "INSERT", "StModeInsert" },
  ["ix"]    = { "INSERT", "StModeInsert" },
  ["R"]     = { "REPLACE", "StModeReplace" },
  ["Rc"]    = { "REPLACE", "StModeReplace" },
  ["Rx"]    = { "REPLACE", "StModeReplace" },
  ["Rv"]    = { "V-REPL", "StModeReplace" },
  ["Rvc"]   = { "V-REPL", "StModeReplace" },
  ["Rvx"]   = { "V-REPL", "StModeReplace" },
  ["c"]     = { "CMD", "StModeCommand" },
  ["cv"]    = { "VIM-EX", "StModeCommand" },
  ["ce"]    = { "EX", "StModeCommand" },
  ["r"]     = { "PROMPT", "StModeCommand" },
  ["rm"]    = { "MORE", "StModeCommand" },
  ["r?"]    = { "CONFIRM", "StModeCommand" },
  ["!"]     = { "SHELL", "StModeCommand" },
  ["t"]     = { "TERM", "StModeTerminal" },
}

-- Mode-pill base hl -> catppuccin palette key. Used to generate a matching
-- separator highlight (mode_color over section bg) for every mode.
-- Operator pills (Yank/Delete/Change/Format/Rchar) mirror modes.nvim's
-- cursorline tints so the pill colour matches the line flash.
local mode_color_key = {
  StModeNormal   = "blue",
  StModeInsert   = "green",
  StModeVisual   = "mauve",
  StModeReplace  = "red",
  StModeCommand  = "peach",
  StModeTerminal = "teal",
  StModeYank     = "yellow",
  StModeDelete   = "red",
  StModeChange   = "teal",
  StModeFormat   = "peach",
  StModeRchar    = "blue",
}

-- Transient operator/replace-char pill. Set by the ModeChanged / on_key
-- handlers in M.setup() and consulted by current_mode_info() so the pill
-- reflects a yank/delete/change/format/replace-char the instant it fires,
-- instead of flickering through the microsecond-long `no*` mode.
local transient = nil    ---@type { label: string, hl: string }?
local transient_timer = nil

local function show_transient(label, hl, ms)
  transient = { label = label, hl = hl }
  if transient_timer then pcall(function() transient_timer:stop() end) end
  transient_timer = vim.defer_fn(function()
    transient = nil
    transient_timer = nil
    pcall(vim.cmd, "redrawstatus")
  end, ms or 400)
  pcall(vim.cmd, "redrawstatus")
end

-- User content (filenames, branch names) can contain `%` which the
-- statusline parser otherwise treats as a format escape.
local function esc(s)
  return (tostring(s):gsub("%%", "%%%%"))
end

local function setup_highlights()
  local p = require("utils").get_palette()
  local set = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

  -- Section backgrounds. Three shades from the catppuccin palette give
  -- the graduated "valley" effect of a classic powerline statusline.
  set("StSecB", { fg = p.text, bg = p.surface0 })
  set("StSecC", { fg = p.subtext1, bg = p.mantle })
  set("StSecX", { fg = p.text, bg = p.surface0 })
  set("StSecY", { fg = p.subtext0, bg = p.surface1 })
  set("StFill", { fg = p.subtext1, bg = p.mantle }) -- inactive statusline

  -- Mode pills + per-mode separator highlights.
  -- <mode_hl>ToB: a -> b transition (right arrow)
  -- <mode_hl>ToC: a -> c transition (right arrow, when b is empty)
  -- <mode_hl>ToY: y -> z transition (left arrow)
  for hl, color_key in pairs(mode_color_key) do
    local color = p[color_key]
    set(hl, { fg = p.base, bg = color, bold = true })
    set(hl .. "ToB", { fg = color, bg = p.surface0 })
    set(hl .. "ToC", { fg = color, bg = p.mantle })
    set(hl .. "ToY", { fg = color, bg = p.surface1 })
  end

  -- Fixed (non-mode-dependent) transitions. Same fg/bg pair is reused for
  -- the b -> c right arrow and the c -> x left arrow — both draw
  -- surface0 against mantle, only the arrow direction differs.
  set("StSepBC", { fg = p.surface0, bg = p.mantle })
  set("StSepXY", { fg = p.surface1, bg = p.surface0 })

  -- Thin component separators inside b and x. Both sections share surface0
  -- background, so a single hl group covers both sides — the glyph itself
  -- chooses the visual direction.
  set("StCompSep", { fg = p.overlay0, bg = p.surface0 })

  -- In-section foregrounds (all on surface0 so they sit inside b / x).
  set("StBranch", { fg = p.mauve, bg = p.surface0, bold = true })
  set("StDiffAdd", { fg = p.green, bg = p.surface0 })
  set("StDiffChange", { fg = p.yellow, bg = p.surface0 })
  set("StDiffDel", { fg = p.red, bg = p.surface0 })
  set("StDiagError", { fg = p.red, bg = p.surface0 })
  set("StDiagWarn", { fg = p.yellow, bg = p.surface0 })
  set("StDiagInfo", { fg = p.sky, bg = p.surface0 })
  set("StDiagHint", { fg = p.teal, bg = p.surface0 })
  set("StArrow", { fg = p.peach, bg = p.surface0, bold = true })
  set("StArrowLine", { fg = p.sky, bg = p.surface0 })

  -- Named labels for special-filetype buffers (see `special_names`). Bg
  -- must match StSecC's (mantle) so the label is seamless within the c
  -- section.
  set("StSpecialExplorer", { fg = p.blue, bg = p.mantle, bold = true })
end

-- Filetype -> styled label override for section_filename. When matched,
-- we skip the filename/modified/readonly/new decorations and render the
-- label inline with the surrounding StSecC (setting hl then restoring).
-- Populated from `opts.special_names` in `setup()`.
local special_names = {}

-- === Section builders ==================================================

local function current_mode_info()
  if transient then return { transient.label, transient.hl } end
  local m = vim.api.nvim_get_mode().mode
  return mode_info[m] or { m:upper(), "StModeNormal" }
end

local function section_branch()
  local head = vim.b.gitsigns_head
  if not head or head == "" then return "" end
  return "%@v:lua.statusline_click_branch@%#StBranch#" .. ICON_BRANCH .. " " .. esc(head) .. "%X"
end

local function section_diff()
  local d = vim.b.gitsigns_status_dict
  if type(d) ~= "table" then return "" end
  local parts = {}
  if d.added and d.added > 0 then table.insert(parts, "%#StDiffAdd#+" .. d.added) end
  if d.changed and d.changed > 0 then table.insert(parts, "%#StDiffChange#~" .. d.changed) end
  if d.removed and d.removed > 0 then table.insert(parts, "%#StDiffDel#-" .. d.removed) end
  if #parts == 0 then return "" end
  return "%@v:lua.statusline_click_diff@" .. table.concat(parts, " ") .. "%X"
end

-- Project-wide arrow marks: file count + line count. Pulled from our
-- side-car index (see lua/neonvim/arrow_project.lua) rather than arrow
-- itself — arrow only knows line marks for currently-loaded buffers, so
-- asking arrow for a project total would under-count.
-- Wrapped defensively: any throw here bricks M.active() and drops the
-- whole statusline into its fallback render, which looks like the bar
-- has disappeared.
local function section_arrow()
  local ok, ap = pcall(require, "neonvim.arrow_project")
  if not ok or type(ap) ~= "table" or type(ap.count) ~= "function" then return "" end
  local c_ok, c = pcall(ap.count)
  if not c_ok or type(c) ~= "table" then return "" end
  local files = tonumber(c.files) or 0
  local lines = tonumber(c.line_marks) or 0
  if files == 0 and lines == 0 then return "" end
  local parts = {}
  if files > 0 then
    parts[#parts + 1] = "%#StArrow#" .. files .. "f"
  end
  if lines > 0 then
    parts[#parts + 1] = "%#StArrowLine#" .. lines .. "l"
  end
  return "%@v:lua.statusline_click_arrow@%#StArrow#" .. ICON_ARROW .. " " ..
      table.concat(parts, " ") .. "%X"
end

local function section_diagnostics()
  local counts = vim.diagnostic.count(0)
  local e = counts[vim.diagnostic.severity.ERROR] or 0
  local w = counts[vim.diagnostic.severity.WARN] or 0
  local i = counts[vim.diagnostic.severity.INFO] or 0
  local h = counts[vim.diagnostic.severity.HINT] or 0
  local parts = {}
  if e > 0 then table.insert(parts, "%#StDiagError#" .. ICON_DIAG_ERR .. " " .. e) end
  if w > 0 then table.insert(parts, "%#StDiagWarn#" .. ICON_DIAG_WARN .. " " .. w) end
  if i > 0 then table.insert(parts, "%#StDiagInfo#" .. ICON_DIAG_INFO .. " " .. i) end
  if h > 0 then table.insert(parts, "%#StDiagHint#" .. ICON_DIAG_HINT .. " " .. h) end
  if #parts == 0 then return "" end
  return "%@v:lua.statusline_click_diag@" .. table.concat(parts, " ") .. "%X"
end

-- `filereadable()` is a filesystem stat; calling it from the statusline on
-- every redraw is avoidable since file-on-disk state only changes on
-- load/write. We cache the result in a buffer-local var, refreshed by
-- BufEnter/BufReadPost/BufNewFile/BufWritePost in M.setup().
--
-- We resolve the buffer via `g:statusline_winid` so the inactive half of
-- a split shows *its own* buffer name, not whichever buffer happens to be
-- current at evaluation time.
local function section_filename()
  local winid = tonumber(vim.g.statusline_winid)
  local bufnr = (winid and vim.api.nvim_win_is_valid(winid))
      and vim.api.nvim_win_get_buf(winid) or 0
  local special = special_names[vim.bo[bufnr].filetype]
  if special then
    return "%#" .. special.hl .. "#" .. esc(special.label) .. "%#StSecC#"
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  local display = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
  local parts = { esc(display) }
  if vim.bo[bufnr].modified then
    table.insert(parts, " \u{25CF}") -- ● matches tabline modified glyph
  end
  if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
    table.insert(parts, "[-]")
  end
  if name ~= "" and vim.b[bufnr].statusline_is_new then
    table.insert(parts, "[+]")
  end
  return table.concat(parts, "")
end

local function section_encoding()
  return (vim.bo.fileencoding ~= "" and vim.bo.fileencoding) or vim.o.encoding
end

local function section_fileformat()
  local ff = vim.bo.fileformat
  local icon = ff == "unix" and ICON_FF_UNIX
      or ff == "dos" and ICON_FF_DOS
      or ff == "mac" and ICON_FF_MAC
      or ""
  if icon == "" then return ff end
  return icon .. " " .. ff
end

local function section_filetype()
  local ft = vim.bo.filetype
  if ft == "" then return "" end
  local icon = ""
  local ok, mi = pcall(require, "mini.icons")
  if ok then
    local ic = mi.get("filetype", ft)
    if ic then icon = ic .. " " end
  end
  return "%@v:lua.statusline_click_filetype@" .. icon .. ft .. "%X"
end

-- True when any attached LSP client has unfinished progress work. Checked
-- via :pairs() on the client's ring-buffer — a "begin" without a matching
-- "end" means the client is still working. Wrapped in pcall because the
-- progress field's shape has shifted between Neovim releases.
local function lsp_in_progress(clients)
  for _, c in ipairs(clients) do
    local prog = c.progress
    if prog then
      local ok, iter = pcall(function() return prog:pairs() end)
      if ok and iter then
        for _, msg in iter do
          if type(msg) == "table" and msg.value and msg.value.kind ~= "end" then
            return true
          end
        end
      end
    end
  end
  return false
end

-- Any client across the whole editor currently showing progress. Cheaper
-- variant used by the spinner timer to decide whether to force a redraw.
local function any_lsp_in_progress()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then return false end
  return lsp_in_progress(clients)
end

local function section_lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  local names = {}
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
  end
  local icon = lsp_in_progress(clients) and spinner_frames[spinner_idx] or ICON_LSP_OK
  return "%@v:lua.statusline_click_lsp@" .. ICON_LSP .. " " .. table.concat(names, " ") .. "%X" .. " " .. icon
end

local function section_selcount()
  local m = vim.api.nvim_get_mode().mode
  local c = m:sub(1, 1)
  if not (c == "v" or c == "V" or c == "s" or c == "S" or c == "\22" or c == "\19") then
    return ""
  end
  local lines = math.abs(vim.fn.line(".") - vim.fn.line("v")) + 1
  local chars = vim.fn.wordcount().visual_chars or 0
  return lines .. "L " .. chars .. "C"
end

local function section_progress()
  return ICON_PROGRESS .. " %p%%"
end

local function section_location()
  return ICON_LOCATION .. " %3l:%-2c"
end

-- Aggregate sections --------------------------------------------------

local function build_b()
  local items = {}
  local br = section_branch(); if br ~= "" then table.insert(items, br) end
  local df = section_diff(); if df ~= "" then table.insert(items, df) end
  local dg = section_diagnostics(); if dg ~= "" then table.insert(items, dg) end
  local ar = section_arrow(); if ar ~= "" then table.insert(items, ar) end
  return items
end

local function build_x()
  local items = { section_encoding(), section_fileformat() }
  local ft = section_filetype(); if ft ~= "" then table.insert(items, ft) end
  local ls = section_lsp(); if ls ~= "" then table.insert(items, ls) end
  return items
end

local function build_y()
  local items = {}
  local sc = section_selcount(); if sc ~= "" then table.insert(items, sc) end
  table.insert(items, section_progress())
  return items
end

-- === Active / inactive rendering ======================================

function M.active()
  local mode = current_mode_info()
  local mode_hl = mode[2]

  local parts = { "%#" .. mode_hl .. "# " .. mode[1] .. " " }

  local b_items = build_b()
  if #b_items == 0 then
    table.insert(parts, "%#" .. mode_hl .. "ToC#" .. SEP_R)
  else
    local b_join = " %#StCompSep#" .. COMP_SEP_R .. "%#StSecB# "
    table.insert(parts, "%#" .. mode_hl .. "ToB#" .. SEP_R)
    table.insert(parts, "%#StSecB# " .. table.concat(b_items, b_join) .. " ")
    table.insert(parts, "%#StSepBC#" .. SEP_R)
  end

  table.insert(parts, "%#StSecC# " .. section_filename() .. " ")
  table.insert(parts, "%=")

  -- Right side: always populated, always C <- X <- Y <- Z
  local x_join = " %#StCompSep#" .. COMP_SEP_L .. "%#StSecX# "
  table.insert(parts, "%#StSepBC#" .. SEP_L)
  table.insert(parts, "%#StSecX# " .. table.concat(build_x(), x_join) .. " ")
  table.insert(parts, "%#StSepXY#" .. SEP_L)
  table.insert(parts, "%#StSecY# " .. table.concat(build_y(), " ") .. " ")
  table.insert(parts, "%#" .. mode_hl .. "ToY#" .. SEP_L)
  table.insert(parts, "%#" .. mode_hl .. "# " .. section_location() .. " ")

  return table.concat(parts, "")
end

function M.inactive()
  return "%#StFill# " .. section_filename() .. " "
end

-- === Globals referenced by `%!` and `%@ ... @` =========================

-- Wrapped in pcall because returning an empty/error string from a `%!`
-- expression causes Neovim to paint a blank statusline row — on a busy
-- day any transient error in one section would wipe the whole bar.
function _G.statusline()
  local winid = tonumber(vim.g.statusline_winid)
  local active = winid and winid == vim.api.nvim_get_current_win()
  local ok, result = pcall(active and M.active or M.inactive)
  if ok and type(result) == "string" and result ~= "" then
    return result
  end
  -- Last-resort fallback: never return empty from `%!`.
  return "%#StFill# " ..
  (vim.fn.bufname("%") ~= "" and vim.fn.fnamemodify(vim.fn.bufname("%"), ":t") or "[No Name]") .. " "
end

function _G.statusline_click_branch()
  require("fzf-lua").git_branches()
end

function _G.statusline_click_diff()
  require("fzf-lua").git_status()
end

function _G.statusline_click_diag()
  require("fzf-lua").diagnostics_workspace()
end

function _G.statusline_click_filetype()
  require("fzf-lua").filetypes()
end

function _G.statusline_click_lsp()
  vim.cmd("LspInfo")
end

function _G.statusline_click_arrow()
  local ok, ap = pcall(require, "neonvim.arrow_project")
  if ok then ap.pick() end
end

-- === Setup ============================================================

local spinner_timer = nil

--- @class neonvim.statusline.SpecialName
--- @field label string Text shown in place of the filename.
--- @field hl string Highlight group for the label; bg should match StSecC.

--- @class neonvim.statusline.Opts
--- @field special_names? table<string, neonvim.statusline.SpecialName>
---   Filetype -> styled label override for the filename section. Default
---   labels all three snacks picker windows (input/list/preview) as
---   "File Explorer" — when toggling the explorer the focused window is
---   the input, not the list.

--- @param opts? neonvim.statusline.Opts
function M.setup(opts)
  opts = opts or {}
  if opts.special_names then
    special_names = opts.special_names
  else
    local explorer = { label = "File Explorer", hl = "StSpecialExplorer" }
    special_names = {
      snacks_layout_box = explorer,
      snacks_picker_input = explorer,
      snacks_picker_list = explorer,
      snacks_picker_preview = explorer,
    }
  end

  setup_highlights()
  local augroup = require("utils").augroup("Statusline")
  -- Re-apply highlights after :colorscheme or :BackgroundToggle reloads.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = setup_highlights,
  })

  -- Refresh the "file doesn't exist on disk yet" flag only when the buffer
  -- actually enters, loads, or is written — not on every redraw.
  vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "BufWritePost" }, {
    group = augroup,
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      vim.b[ev.buf].statusline_is_new = name ~= "" and vim.fn.filereadable(name) == 0
    end,
  })

  -- Since we no longer force a redraw every 300ms, the statusline shows
  -- stale state until the next natural redraw. Nudge it on the events
  -- that actually change what's rendered — content events
  -- (DiagnosticChanged, LspAttach/Detach) and window-topology events
  -- (WinEnter, WinClosed). The latter matter because Neovim's implicit
  -- redraw after :close sometimes doesn't land when the close happens
  -- inside a keymap callback (e.g. close_with_q's `q` handler closing a
  -- checkhealth split leaves the remaining window with an un-repainted
  -- statusline row). LspProgress is intentionally excluded — the
  -- spinner_timer below repaints during in-flight progress (and the
  -- final ✓ lands within one 300ms tick of "end"), so adding it here
  -- would stack dozens of per-second redraws during indexing.
  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach", "WinEnter", "WinClosed" }, {
    group = augroup,
    callback = function() vim.cmd("redrawstatus") end,
  })

  -- Operator-pending pill. The `*:no*` transition fires the instant the
  -- user presses y/d/c/=/>/<; vim.v.operator tells us which. By the time
  -- mode returns to `n` the motion has executed, so we show the pill for
  -- ~400ms regardless of how short the operator window was. Format
  -- operators (`=`, `<`, `>`, `gq`, `!`) all collapse into one FORMAT
  -- pill — the user just needs to know an operator fired, not which.
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = augroup,
    pattern = "*:no*",
    callback = function()
      local op = vim.v.operator
      if op == "y" then
        show_transient("YANK", "StModeYank")
      elseif op == "d" then
        show_transient("DELETE", "StModeDelete")
      elseif op == "c" then
        show_transient("CHANGE", "StModeChange")
      elseif op:match("[=!><g]") then
        show_transient("FORMAT", "StModeFormat")
      end
    end,
  })

  -- Single-char replace (`r<x>`) doesn't fire ModeChanged — Neovim handles
  -- it in one keystroke. vim.on_key lets us surface it the same way
  -- modes.nvim does for its cursorline tint.
  vim.on_key(function(key)
    if key ~= "r" then return end
    local m = vim.api.nvim_get_mode().mode
    if m == "n" or m:match("^ni") or m:match("^[vV\22]") then
      show_transient("R-CHAR", "StModeRchar")
    end
  end)

  -- Arrow mark changes don't surface through any standard event; the plugin
  -- fires User autocmds after every update, so hook those too. The redraw
  -- is scheduled because ArrowMarkUpdate fires from inside BufReadPost via
  -- arrow's own load path — redrawing synchronously during that event
  -- sometimes paints over mid-render UI state, leaving the bar blank until
  -- the next natural redraw.
  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = { "ArrowUpdate", "ArrowMarkUpdate" },
    callback = function()
      vim.schedule(function() pcall(vim.cmd, "redrawstatus") end)
    end,
  })

  vim.opt.statusline = "%!v:lua.statusline()"

  -- Stop a prior timer if setup() is called again (e.g. after :luafile or
  -- a dev reload) — otherwise timers accumulate and the spinner ticks N
  -- times faster than intended.
  if spinner_timer then
    pcall(function() spinner_timer:stop() end)
    pcall(function() spinner_timer:close() end)
    spinner_timer = nil
  end

  -- 300ms heartbeat: drives the LSP spinner animation AND serves as a
  -- safety net against missed implicit redraws (closing floats, plugin
  -- callbacks that exit cmdline weirdly, etc.). We use `redrawstatus`
  -- without the bang — that only repaints the *current* window's status
  -- row, which is one row per tick. The old implementation used
  -- `redrawstatus!` (all windows) and was the expensive part; the timer
  -- itself is fine. Inactive windows' status content is static
  -- (filename only), so they don't need a heartbeat — WinEnter/WinClosed
  -- autocmds above cover their transitions.
  spinner_timer = assert(vim.uv.new_timer())
  spinner_timer:start(300, 300, vim.schedule_wrap(function()
    if any_lsp_in_progress() then
      spinner_idx = (spinner_idx % #spinner_frames) + 1
    end
    vim.cmd("redrawstatus")
  end))
end

-- Expose re-theming helper for 01-catppuccin.lua's reload path.
M.refresh_highlights = setup_highlights

return M
