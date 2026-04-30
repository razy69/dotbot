-- Visual-feedback primitive: paint a region with a highlight group for a
-- short timeout, then clear. Replaces undo-glow.nvim with ~80 lines and no
-- external deps. Neovim's `vim.hl.on_yank` already covers yank; this module
-- adds equivalents for undo / redo / paste / search / focus-gained.

local M = {}

local ns = vim.api.nvim_create_namespace("neonvim.glow")

--- Paint a region with `hl` for `timeout_ms`, then clear.
--- Coordinates are 0-indexed (matches extmark API). Marks spanning multiple
--- lines are set with `end_row`/`end_col`; single-line ranges reduce to one
--- extmark. Priority > 100 overlays treesitter but yields to diagnostic
--- squiggles (which live above 200).
---@param bufnr integer
---@param start_row integer 0-indexed
---@param start_col integer 0-indexed
---@param end_row integer 0-indexed, inclusive
---@param end_col integer 0-indexed, exclusive (may be 0 when end_row > start_row)
---@param hl string highlight group name
---@param timeout_ms integer
function M.region(bufnr, start_row, start_col, end_row, end_col, hl, timeout_ms)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if start_row >= line_count then return end
  end_row = math.min(end_row, line_count - 1)

  local id = vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col, {
    end_row = end_row,
    end_col = end_col,
    hl_group = hl,
    hl_eol = false,
    priority = 150,
  })
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, id)
    end
  end, timeout_ms)
end

--- TextYankPost handler — delegates to Neovim's built-in yank highlight.
--- `on_visual = true` so visual-mode yanks flash the selection too.
function M.yank()
  vim.hl.on_yank({ higroup = "GlowYank", timeout = 500, on_visual = true })
end

--- Flash the region bracketed by the `[` and `]` marks — these are set by
--- Neovim after every change (undo/redo/paste/edit), so this works for all
--- three without needing separate logic per operator.
---@param hl string
---@param timeout_ms? integer default 500
function M.last_changed(hl, timeout_ms)
  local bufnr = vim.api.nvim_get_current_buf()
  local lo = vim.api.nvim_buf_get_mark(bufnr, "[")
  local hi = vim.api.nvim_buf_get_mark(bufnr, "]")
  -- marks are (1-indexed row, 0-indexed col); extmarks want 0-indexed row.
  if lo[1] == 0 or hi[1] == 0 then return end
  local sr, sc = lo[1] - 1, lo[2]
  local er, ec = hi[1] - 1, hi[2]
  -- `]` col is the last char of the change; extmark end_col is exclusive,
  -- so extend by one (clamped to line length) to include that char.
  local last_line = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, false)[1] or ""
  ec = math.min(ec + 1, #last_line)
  if sr == er and sc >= ec then return end
  M.region(bufnr, sr, sc, er, ec, hl, timeout_ms or 500)
end

--- Flash the current cursor line — used on FocusGained to visually anchor
--- the user after a tmux / window switch.
function M.current_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
  M.region(bufnr, row, 0, row, #line, "GlowCursor", 300)
end

--- Flash the current search match. Called after `n`/`N`/`*`/`#` and after
--- leaving the `/` or `?` cmdline. `searchpos` uses a non-moving `n` flag
--- so the cursor doesn't jump to re-locate the match.
function M.search_match()
  local pattern = vim.fn.getreg("/")
  if pattern == "" then return end
  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.fn.searchpos(pattern, "cnw")
  local row, col = pos[1], pos[2]
  if row == 0 then return end
  local match = vim.fn.matchstr(vim.fn.getline(row), pattern)
  if match == "" then return end
  M.region(bufnr, row - 1, col - 1, row - 1, col - 1 + #match, "GlowSearch", 400)
end

return M
