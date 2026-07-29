-- Peek at the target line while typing `:<number>` in command-line mode.
-- Restores the original view if the command is aborted; lets native `:<number>`
-- handle the jump on confirmation.
local M = {}

local saved = nil
-- Last line we actually scrolled to, so repeated CmdlineChanged events that
-- resolve to the same target are free. Cleared alongside `saved`.
local peeked_line = nil

local function peek(line)
  if not saved then
    saved = {
      win = vim.api.nvim_get_current_win(),
      buf = vim.api.nvim_get_current_buf(),
      view = vim.fn.winsaveview(),
    }
  end
  -- nvim_buf_line_count is never 0 (an empty buffer still has one line), so
  -- there is no zero-line case to guard.
  local total = vim.api.nvim_buf_line_count(0)
  line = math.max(1, math.min(line, total))
  -- Skip the cursor move, `zz` and the screen flush when the target hasn't
  -- moved — every extra digit past the end of the buffer clamps to the same
  -- line (`:999`, `:9999`, ...), and CmdlineChanged can fire without the
  -- resolved number changing.
  if peeked_line == line then return end
  peeked_line = line
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd("normal! zz")
  -- The forced redraw is required, not cosmetic: while the cmdline is open
  -- Neovim does not repaint the window between keystrokes, so without this
  -- the peek is invisible until the cmdline closes. (numb.nvim forces it
  -- for the same reason.)
  vim.cmd("redraw")
end

--- Drop the snapshot and the peeked-line memo together — they must never
--- outlive each other, or a later peek() reuses a stale target/view.
local function clear_saved()
  saved = nil
  peeked_line = nil
end

local function restore()
  if saved
      and vim.api.nvim_win_is_valid(saved.win)
      and vim.api.nvim_win_get_buf(saved.win) == saved.buf
  then
    vim.api.nvim_win_call(saved.win, function()
      vim.fn.winrestview(saved.view)
    end)
  end
  clear_saved()
end

function M.setup()
  local group = require("utils").augroup("numb_peek")

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = function()
      if vim.fn.getcmdtype() ~= ":" then
        return
      end
      local cmd = vim.fn.getcmdline()
      local n = cmd:match("^%s*(%d+)%s*$")
      if n then
        peek(tonumber(n))
      elseif saved then
        -- Cmdline diverged from a pure-number form (e.g. `:42` -> `:42s`).
        -- Snap the view back so unrelated commands aren't issued from a
        -- preview position.
        restore()
      end
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      -- `saved` must be cleared on *every* cmdline leave, whatever the
      -- cmdline type. Returning early for a non-`:` cmdline left a stale
      -- snapshot behind, so the next peek() skipped taking its own and a
      -- later restore() wrote that stale view into the current window.
      if vim.fn.getcmdtype() ~= ":" then
        clear_saved()
        return
      end
      if vim.v.event.abort then
        restore()
      else
        -- Confirmed: native `:<number>` will jump to the line, so just clear
        -- our saved view.
        clear_saved()
      end
    end,
  })
end

return M
