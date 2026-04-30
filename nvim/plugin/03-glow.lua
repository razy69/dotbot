-- Visual feedback for yank/undo/redo/paste/search/focus. Replaces
-- undo-glow.nvim with an in-tree module (see lua/neonvim/glow.lua).
local glow = require("neonvim.glow")

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Flash on yank",
  callback = glow.yank,
})

vim.api.nvim_create_autocmd("FocusGained", {
  desc = "Flash cursor line on focus-gained",
  callback = glow.current_line,
})

-- `/` and `?` leaving the cmdline lands the cursor on the first match;
-- schedule so the search-position is final before we resolve it.
vim.api.nvim_create_autocmd("CmdlineLeave", {
  desc = "Flash match on search",
  pattern = { "/", "?" },
  callback = function() vim.schedule(glow.search_match) end,
})

-- Wrap motion keys so the affected region flashes after the motion. We feed
-- the raw key via nvim_feedkeys (no remap), then schedule the flash —
-- scheduling lets Neovim update the `[` / `]` marks before `last_changed`
-- reads them. `replace_termcodes` turns `<C-r>` into the literal keycode so
-- redo actually fires.
local function feed(key)
  local seq = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(seq, "n", false)
end

local function wrap_change(key, hl)
  return function()
    feed(key)
    vim.schedule(function() glow.last_changed(hl) end)
  end
end

local function wrap_search(key)
  return function()
    feed(key)
    vim.schedule(glow.search_match)
  end
end

utils.wk_add({
  { "u", wrap_change("u", "GlowUndo"),      desc = "Undo with highlight",        mode = "n" },
  { "U", wrap_change("<C-r>", "GlowRedo"),  desc = "Redo with highlight",        mode = "n" },
  { "p", wrap_change("p", "GlowPaste"),     desc = "Paste below with highlight", mode = "n" },
  { "P", wrap_change("P", "GlowPaste"),     desc = "Paste above with highlight", mode = "n" },
  { "n", wrap_search("n"),                  desc = "Search next with highlight", mode = "n" },
  { "N", wrap_search("N"),                  desc = "Search prev with highlight", mode = "n" },
  { "*", wrap_search("*"),                  desc = "Search star with highlight", mode = "n" },
  { "#", wrap_search("#"),                  desc = "Search hash with highlight", mode = "n" },
})
