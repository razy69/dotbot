-- Peek at the target line while typing `:<number>` in command-line mode.
-- Restores the original view if the command is aborted; lets native `:<number>`
-- handle the jump on confirmation.
local M = {}

local saved = nil

local function peek(line)
  if not saved then
    saved = {
      win = vim.api.nvim_get_current_win(),
      buf = vim.api.nvim_get_current_buf(),
      view = vim.fn.winsaveview(),
    }
  end
  local total = vim.api.nvim_buf_line_count(0)
  if total == 0 then
    return
  end
  line = math.max(1, math.min(line, total))
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd("normal! zz")
  vim.cmd("redraw")
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
  saved = nil
end

function M.setup()
  local group = vim.api.nvim_create_augroup("neonvim_numb_peek", { clear = true })

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
      if vim.fn.getcmdtype() ~= ":" then
        return
      end
      if vim.v.event.abort then
        restore()
      else
        -- Confirmed: native `:<number>` will jump to the line, so just clear
        -- our saved view.
        saved = nil
      end
    end,
  })
end

return M
