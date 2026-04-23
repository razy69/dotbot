---@brief Lightweight tabline, replaces bufferline in "tabs" mode. Each
--- tab shows: [icon] [filename] [status symbol] [close button]. Catppuccin
--- supplies TabLine / TabLineSel / TabLineFill as the base; the icon fg is
--- pulled per-filetype from mini.icons' color groups (matching snacks
--- explorer), and the status symbol reflects VSCode-style new/modified/saved.

local M = {}

-- Status glyphs (Nerd Font). `SYMBOL_CLOSE` is the always-present × click
-- target; `SYMBOL_NEW` / `SYMBOL_MODIFIED` sit to its left when applicable.
local SYMBOL_NEW      = "\u{271A}" -- ✚ never saved to disk
local SYMBOL_MODIFIED = "\u{25CF}" -- ● unsaved changes
local SYMBOL_CLOSE    = "\u{00D7}" -- ×

-- Derived-highlight cache, keyed by "<base>:<src>". Entries combine the src
-- group's fg with the base (TabLine / TabLineSel) bg, because neither
-- mini.icons' `MiniIcons*` groups nor our `TablineStatus*` groups carry a
-- tabline-matching background. Cleared on ColorScheme to pick up new palette.
local hl_cache        = {}

-- Filetypes whose windows should not drive a tab's displayed buffer. When
-- the focused window of a tab matches, we walk the other windows and pick
-- the first non-excluded one, falling back to the focused window if all
-- are excluded. Populated from `opts.exclude_filetypes` in `setup()`.
local exclude_fts     = {}

local function esc(s)
  return (tostring(s):gsub("%%", "%%%%"))
end

local function get_hl_attr(name, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then return nil end
  return hl[attr]
end

local function derive_hl(base, src)
  local key = base .. ":" .. src
  local cached = hl_cache[key]
  if cached ~= nil then return cached end
  local fg = get_hl_attr(src, "fg")
  local bg = get_hl_attr(base, "bg")
  if fg and bg then
    local name = "Tabline_" .. base .. "_" .. src
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    hl_cache[key] = name
    return name
  end
  hl_cache[key] = base
  return base
end

local function get_icon(ft)
  if ft == "" then return "", nil end
  local ok, mi = pcall(require, "mini.icons")
  if not ok then return "", nil end
  local icon, hl = mi.get("filetype", ft)
  return (icon or ""), hl
end

-- New beats modified: for a brand-new unsaved buffer we care more about
-- "this has never been written" than the redundant "has unsaved changes".
local function status(buf, raw_name)
  if raw_name ~= "" and vim.b[buf].tabline_is_new then
    return SYMBOL_NEW, "TablineStatusNew"
  end
  if vim.bo[buf].modified then
    return SYMBOL_MODIFIED, "TablineStatusModified"
  end
  return nil, nil
end

local function pick_buf(tab_handle)
  local focused = vim.api.nvim_tabpage_get_win(tab_handle)
  local buf = vim.api.nvim_win_get_buf(focused)
  if not exclude_fts[vim.bo[buf].filetype] then return buf end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab_handle)) do
    local b = vim.api.nvim_win_get_buf(win)
    if not exclude_fts[vim.bo[b].filetype] then return b end
  end
  return buf
end

local function format_tab(idx, tab_handle, is_current, closable)
  local buf = pick_buf(tab_handle)
  local raw_name = vim.api.nvim_buf_get_name(buf)
  local ft = vim.bo[buf].filetype

  local fname = raw_name == "" and "[No Name]" or vim.fn.fnamemodify(raw_name, ":t")
  local base = is_current and "TabLineSel" or "TabLine"

  local icon, icon_src = get_icon(ft)
  local sym, sym_src = status(buf, raw_name)

  local out = { "%" .. idx .. "T", "%#", base, "# " }
  if icon ~= "" then
    local hl = icon_src and derive_hl(base, icon_src) or base
    table.insert(out, "%#" .. hl .. "#" .. icon .. " %#" .. base .. "#")
  end
  table.insert(out, esc(fname))
  if sym then
    table.insert(out, " %#" .. derive_hl(base, sym_src) .. "#" .. sym .. "%#" .. base .. "#")
  end
  -- Hide × on a lone tab: `:tabclose` on the last tab errors (E784) and
  -- would leave the click target non-functional.
  if closable then
    table.insert(out, " %" .. idx .. "X" .. SYMBOL_CLOSE .. "%X ")
  else
    table.insert(out, " ")
  end

  return table.concat(out)
end

function _G.tabline()
  local tabs = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()
  local closable = #tabs > 1
  local parts = {}
  for i, tab in ipairs(tabs) do
    table.insert(parts, format_tab(i, tab, tab == current, closable))
  end
  table.insert(parts, "%#TabLineFill#%T")
  return table.concat(parts, "")
end

local function setup_highlights()
  local ok, utils = pcall(require, "utils")
  if not ok then return end
  local p = utils.get_palette()
  vim.api.nvim_set_hl(0, "TablineStatusNew", { fg = p.green })
  vim.api.nvim_set_hl(0, "TablineStatusModified", { fg = p.yellow })
  -- Invalidate derived entries so fg/bg are re-resolved from the freshly
  -- applied TabLine / TablineStatus* groups.
  hl_cache = {}
end

--- @class neonvim.tabline.Opts
--- @field exclude_filetypes? string[] Filetypes whose window should not drive
---   the tab's displayed buffer. The tab will show another window's buffer
---   from the same tab page instead. Default covers the three snacks picker
---   windows (input/list/preview) since the explorer opens with input focused.

--- @param opts? neonvim.tabline.Opts
function M.setup(opts)
  opts = opts or {}
  exclude_fts = {}
  local default = {
    "snacks_layout_box",     -- floating container that wraps the picker windows
    "snacks_picker_input",
    "snacks_picker_list",
    "snacks_picker_preview",
  }
  for _, ft in ipairs(opts.exclude_filetypes or default) do
    exclude_fts[ft] = true
  end

  setup_highlights()
  local augroup = require("utils").augroup("Tabline")

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = setup_highlights,
  })

  -- Cache "file doesn't exist on disk yet" per-buffer so we don't stat() on
  -- every tabline redraw. Same pattern as statusline's `statusline_is_new`.
  vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "BufWritePost" }, {
    group = augroup,
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      vim.b[ev.buf].tabline_is_new = name ~= "" and vim.fn.filereadable(name) == 0
    end,
  })

  vim.opt.tabline = "%!v:lua.tabline()"
  vim.opt.showtabline = 2
end

return M
