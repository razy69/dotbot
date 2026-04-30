-- Replacement for boole.nvim. Cycles known words on <C-a> / <C-x>, falling
-- back to native increment/decrement when no cycle matches.
--
-- Coverage:
--   • Boolean-ish pairs: true/false, yes/no, on/off
--   • Days (full + abbrev): monday..sunday, mon..sun
--   • Months (full + abbrev): january..december, jan..dec
--   • Canonical hours: matins, lauds, prime, terce, sext, none, vespers, compline
--   • X11 / web color names (alphabetical, ~140 entries)
--   • Letter+digit suffixes: F1 -> F2, step12 -> step13 (preserves digit width)

local M = {}

-- Cycles whose words are stored lowercase; case is reapplied via preserve_case.
local CYCLES = {
  { "true",   "false" },
  { "yes",    "no" },
  { "on",     "off" },
  { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
  { "january", "february", "march", "april", "may", "june",
    "july", "august", "september", "october", "november", "december" },
  { "matins", "lauds", "prime", "terce", "sext", "none", "vespers", "compline" },
}

-- Three-letter abbreviations. Resolved before CYCLES when the input is short
-- enough, so `Mar` -> `Apr` instead of being misread as a full month name.
local SHORT_CYCLES = {
  { "mon", "tue", "wed", "thu", "fri", "sat", "sun" },
  { "jan", "feb", "mar", "apr", "may", "jun",
    "jul", "aug", "sep", "oct", "nov", "dec" },
}

-- X11 / web color names, alphabetically ordered (canonical CamelCase).
local COLORS = {
  "AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine", "Azure",
  "Beige", "Bisque", "Black", "BlanchedAlmond", "Blue", "BlueViolet",
  "Brown", "BurlyWood",
  "CadetBlue", "Chartreuse", "Chocolate", "Coral", "CornflowerBlue",
  "Cornsilk", "Crimson", "Cyan",
  "DarkBlue", "DarkCyan", "DarkGoldenRod", "DarkGray", "DarkGreen",
  "DarkKhaki", "DarkMagenta", "DarkOliveGreen", "DarkOrange", "DarkOrchid",
  "DarkRed", "DarkSalmon", "DarkSeaGreen", "DarkSlateBlue", "DarkSlateGray",
  "DarkTurquoise", "DarkViolet", "DeepPink", "DeepSkyBlue", "DimGray",
  "DodgerBlue",
  "FireBrick", "FloralWhite", "ForestGreen", "Fuchsia",
  "Gainsboro", "GhostWhite", "Gold", "GoldenRod", "Gray", "Green",
  "GreenYellow",
  "HoneyDew", "HotPink",
  "IndianRed", "Indigo", "Ivory",
  "Khaki",
  "Lavender", "LavenderBlush", "LawnGreen", "LemonChiffon", "LightBlue",
  "LightCoral", "LightCyan", "LightGoldenRodYellow", "LightGray", "LightGreen",
  "LightPink", "LightSalmon", "LightSeaGreen", "LightSkyBlue", "LightSlateGray",
  "LightSteelBlue", "LightYellow", "Lime", "LimeGreen", "Linen",
  "Magenta", "Maroon", "MediumAquaMarine", "MediumBlue", "MediumOrchid",
  "MediumPurple", "MediumSeaGreen", "MediumSlateBlue", "MediumSpringGreen",
  "MediumTurquoise", "MediumVioletRed", "MidnightBlue", "MintCream", "MistyRose",
  "Moccasin",
  "NavajoWhite", "Navy",
  "OldLace", "Olive", "OliveDrab", "Orange", "OrangeRed", "Orchid",
  "PaleGoldenRod", "PaleGreen", "PaleTurquoise", "PaleVioletRed", "PapayaWhip",
  "PeachPuff", "Peru", "Pink", "Plum", "PowderBlue", "Purple",
  "RebeccaPurple", "Red", "RosyBrown", "RoyalBlue",
  "SaddleBrown", "Salmon", "SandyBrown", "SeaGreen", "SeaShell", "Sienna",
  "Silver", "SkyBlue", "SlateBlue", "SlateGray", "Snow", "SpringGreen",
  "SteelBlue",
  "Tan", "Teal", "Thistle", "Tomato", "Turquoise",
  "Violet",
  "Wheat", "White", "WhiteSmoke",
  "Yellow", "YellowGreen",
}

-- Lookup tables: lowercase word -> { cycle, idx }
local function build_lookup(cycles)
  local out = {}
  for _, cycle in ipairs(cycles) do
    for i, w in ipairs(cycle) do
      out[w] = { cycle = cycle, idx = i }
    end
  end
  return out
end

local CYCLE_LOOKUP = build_lookup(CYCLES)
local SHORT_LOOKUP = build_lookup(SHORT_CYCLES)
local COLOR_LOOKUP = (function()
  local out = {}
  for i, c in ipairs(COLORS) do
    out[c:lower()] = { cycle = COLORS, idx = i, canonical = true }
  end
  return out
end)()

local function preserve_case(src, dst)
  if #src > 1 and src:match("^%u+$") then
    return dst:upper()
  end
  if src:sub(1, 1):match("%u") then
    return dst:sub(1, 1):upper() .. dst:sub(2):lower()
  end
  return dst:lower()
end

local function step(entry, dir)
  local n = #entry.cycle
  local new_idx = ((entry.idx - 1 + dir) % n) + 1
  return entry.cycle[new_idx], new_idx
end

local function find_entry(word)
  local lower = word:lower()
  if #lower <= 3 and SHORT_LOOKUP[lower] then
    return SHORT_LOOKUP[lower]
  end
  if CYCLE_LOOKUP[lower] then
    return CYCLE_LOOKUP[lower]
  end
  if COLOR_LOOKUP[lower] then
    return COLOR_LOOKUP[lower]
  end
  return nil
end

-- Letter+digit pattern: F1 -> F2, step012 -> step013 (preserves digit width)
local function letter_digit_step(word, dir)
  local prefix, num = word:match("^(%a+)(%d+)$")
  if not prefix or not num then
    return nil
  end
  local n = tonumber(num) + dir
  if n < 0 then
    return nil
  end
  return string.format("%s%0" .. #num .. "d", prefix, n)
end

local function compute_replacement(word, dir, count)
  count = count or 1
  local entry = find_entry(word)
  if entry then
    local current_entry = entry
    local last_word
    for _ = 1, count do
      local w, new_idx = step(current_entry, dir)
      last_word = w
      current_entry = { cycle = current_entry.cycle, idx = new_idx, canonical = current_entry.canonical }
    end
    if entry.canonical then
      return last_word
    end
    return preserve_case(word, last_word)
  end

  local cur = word
  for _ = 1, count do
    local nxt = letter_digit_step(cur, dir)
    if not nxt then
      return nil
    end
    cur = nxt
  end
  if cur == word then
    return nil
  end
  return cur
end

-- Locate the keyword surrounding (or after) the cursor on the current line.
-- Returns 0-based row, col_start (inclusive), col_end (exclusive), and the
-- word text. Returns nil if no keyword is reachable.
---@return integer? row, integer? col_start, integer? col_end, string? word
local function locate_word()
  local row = vim.fn.line(".") - 1
  local cursor_col = vim.fn.col(".") - 1 -- 0-based byte
  local line = vim.api.nvim_get_current_line()
  if line == "" then
    return nil
  end
  local s = 1
  while s <= #line do
    local ws, we = line:find("[%w_]+", s)
    if not ws then
      return nil
    end
    -- ws/we are 1-based inclusive
    if cursor_col + 1 >= ws and cursor_col + 1 <= we then
      return row, ws - 1, we, line:sub(ws, we)
    end
    if ws > cursor_col + 1 then
      return row, ws - 1, we, line:sub(ws, we)
    end
    s = we + 1
  end
  return nil
end

local function try_toggle(dir)
  local row, cs, ce, word = locate_word()
  if not row or not cs or not ce or not word then
    return false
  end
  local count = vim.v.count1
  local rep = compute_replacement(word, dir, count)
  if not rep then
    return false
  end
  vim.api.nvim_buf_set_text(0, row, cs, row, ce, { rep })
  -- Mimic native <C-a>: leave cursor on the last char of the replacement.
  vim.api.nvim_win_set_cursor(0, { row + 1, cs + #rep - 1 })
  return true
end

function M.setup()
  local function bump(dir, fallback)
    return function()
      if try_toggle(dir) then
        return
      end
      -- Forward the original count so `5<C-a>` on a number still increments
      -- by 5. "n" mode = no remap, so the fed key hits the built-in.
      local count = vim.v.count
      local prefix = count > 0 and tostring(count) or ""
      vim.api.nvim_feedkeys(
        prefix .. vim.api.nvim_replace_termcodes(fallback, true, false, true),
        "n",
        false
      )
    end
  end

  vim.keymap.set("n", "<C-a>", bump(1, "<C-a>"), { desc = "Increment / cycle word" })
  vim.keymap.set("n", "<C-x>", bump(-1, "<C-x>"), { desc = "Decrement / cycle word" })
end

-- Exposed for tests / debugging.
M._compute = compute_replacement
M._preserve_case = preserve_case
M._locate_word = locate_word

return M
