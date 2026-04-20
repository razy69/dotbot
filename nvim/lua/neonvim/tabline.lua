---@brief Lightweight tabline, replaces bufferline in "tabs" mode. Each
--- tab shows: [icon] [filename] [modified mark] [close button]. Catppuccin
--- supplies TabLine / TabLineSel / TabLineFill highlights, no extra setup.

local M = {}

local function esc(s)
  return (tostring(s):gsub("%%", "%%%%"))
end

local function format_tab(idx, tab_handle, is_current)
  local win = vim.api.nvim_tabpage_get_win(tab_handle)
  local buf = vim.api.nvim_win_get_buf(win)
  local raw_name = vim.api.nvim_buf_get_name(buf)
  local ft = vim.bo[buf].filetype

  local fname = raw_name == "" and "[No Name]" or vim.fn.fnamemodify(raw_name, ":t")
  local icon = ""
  local ok, mi = pcall(require, "mini.icons")
  if ok and ft ~= "" then
    local ic = mi.get("filetype", ft)
    if ic then icon = ic .. " " end
  end

  local modified = vim.bo[buf].modified and " \u{25CF}" or "" -- ●
  local hl = is_current and "%#TabLineSel#" or "%#TabLine#"

  -- %<N>T starts a click region that switches to tab N (ends at %T).
  -- %<N>X starts a click region that closes tab N (ends at %X).
  return table.concat({
    hl,
    "%", idx, "T",
    " ", icon, esc(fname), modified, " ",
    "%", idx, "X", "\u{00D7}", "%X",
    " ",
  })
end

function _G.tabline()
  local tabs = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()
  local parts = {}
  for i, tab in ipairs(tabs) do
    table.insert(parts, format_tab(i, tab, tab == current))
  end
  table.insert(parts, "%#TabLineFill#%T")
  return table.concat(parts, "")
end

function M.setup()
  vim.opt.tabline = "%!v:lua.tabline()"
  vim.opt.showtabline = 2
end

return M
