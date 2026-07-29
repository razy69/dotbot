-- Visual feedback for yank/undo/redo/paste/search/focus. Replaces
-- undo-glow.nvim with an in-tree module (see lua/neonvim/glow.lua).
--
-- Everything here is post-startup by nature (a yank, a motion, a focus change),
-- so the whole bootstrap is deferred to the first file read rather than run
-- during startup.

local function setup()
  local glow = require("neonvim.glow")
  local group = utils.augroup("glow")

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Flash on yank",
    callback = glow.yank,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    desc = "Flash cursor line on focus-gained",
    callback = glow.current_line,
  })

  -- `/` and `?` leaving the cmdline lands the cursor on the first match;
  -- schedule so the search-position is final before we resolve it.
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    desc = "Flash match on search",
    pattern = { "/", "?" },
    callback = function() vim.schedule(glow.search_match) end,
  })

  -- Wrap motion keys so the affected region flashes after the motion.
  --
  -- The count and (for pastes) the register must be forwarded explicitly:
  -- feeding a bare key turned `3n`, `5u` and `"0p` into count-1, unnamed-register
  -- operations. `v:register` reflects the 'clipboard' default too, so forwarding
  -- it always keeps a plain `p` behaving exactly as configured.
  --
  -- "nx" (rather than "n") executes the pending typeahead before returning, so
  -- the scheduled flash reads the `[` / `]` marks of *this* change instead of
  -- racing the previous one.
  ---@param key string Key sequence to replay
  ---@param with_register boolean Forward v:register (pastes only; invalid for searches)
  local function feed(key, with_register)
    local prefix = with_register and ('"' .. vim.v.register) or ""
    if vim.v.count > 0 then
      prefix = prefix .. vim.v.count
    end
    local seq = vim.api.nvim_replace_termcodes(prefix .. key, true, false, true)
    vim.api.nvim_feedkeys(seq, "nx", false)
  end

  local function wrap_change(key, hl, with_register)
    return function()
      feed(key, with_register or false)
      vim.schedule(function() glow.last_changed(hl) end)
    end
  end

  local function wrap_search(key)
    return function()
      feed(key, false)
      vim.schedule(glow.search_match)
    end
  end

  utils.wk_add({
    { "u", wrap_change("u", "GlowUndo"),        desc = "Undo with highlight",        mode = "n" },
    { "U", wrap_change("<C-r>", "GlowRedo"),    desc = "Redo with highlight",        mode = "n" },
    { "p", wrap_change("p", "GlowPaste", true), desc = "Paste below with highlight", mode = "n" },
    { "P", wrap_change("P", "GlowPaste", true), desc = "Paste above with highlight", mode = "n" },
    { "n", wrap_search("n"),                    desc = "Search next with highlight", mode = "n" },
    { "N", wrap_search("N"),                    desc = "Search prev with highlight", mode = "n" },
    { "*", wrap_search("*"),                    desc = "Search star with highlight", mode = "n" },
    { "#", wrap_search("#"),                    desc = "Search hash with highlight", mode = "n" },
  })
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = utils.augroup("glow_bootstrap"),
  once = true,
  callback = setup,
})
