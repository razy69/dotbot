---@brief Nested LSP hover. Pressing `K` in an already-open hover window
--- resolves the word under the cursor via `workspace/symbol` on the
--- original source buffer's client, then opens another hover on top —
--- repeat to drill as deep as the docs take you.
---
--- Navigation:
---   K      — in source: open/focus top-level hover; in a hover: open
---            nested hover for the word under cursor. Pressing K on a
---            symbol that's already showing focuses its hover instead of
---            duplicating.
---   <Tab>  — cycle forward through open hover windows (hover-only).
---   <S-Tab>— cycle backward.
---   q      — close the topmost (most-recently-opened) hover.
---   Q      — close every open hover at once.
---
--- Why workspace/symbol? The hover buffer isn't attached to any LSP, so
--- a cursor position there is meaningless to an LSP. workspace/symbol
--- lets us ask "which symbol does this identifier name?" and get back a
--- concrete (uri, range) that we can then hover at.
---
--- Disambiguation: workspace/symbol fuzzy-matches — `Response` can hit
--- `http.Response`, `openapi.Response`, etc. We rank candidates against
--- the parent hover's context (same file > same directory > anywhere)
--- so nested lookups resolve in the same package as their parent.

local M = {}

local HOVER_OPTS = {
  border = "rounded",
  max_width = 100,
  max_height = 25,
}

local MIN_HEIGHT = 8
local TOP_FOCUS_ID = "neonvim.hover.top"

-- Stack of open hovers. Each entry is { win = winid, context = {uri, pos} }
-- where `context` is the source location of the hover's subject — used
-- by the next-level lookup to disambiguate ambiguous symbol names.
local stack = {}

-- Monotonically increasing on every K press. Async LSP responses check
-- against the current value and discard themselves if superseded — stops
-- rapid K presses from piling up floats with stale data.
--
-- We deliberately do NOT cancel in-flight LSP requests. A burst of
-- cancel/reissue cycles can leave gopls (and other language servers) in
-- a sluggish or wedged state — losing the cancellations or dropping
-- subsequent requests entirely, which manifests as "K stops working"
-- after a lot of rapid pressing. Letting the server finish its queue
-- and discarding stale results on our side is slower per-request but
-- empirically far more reliable.
local generation = 0

-- === Stack helpers ==================================================

local function close_latest()
  local idx
  for i = #stack, 1, -1 do
    if vim.api.nvim_win_is_valid(stack[i].win) then
      idx = i; break
    end
  end
  if not idx then return end

  -- Park focus on the previous hover before closing, so nvim_win_close
  -- doesn't auto-route focus through the source buffer (which would
  -- trigger CursorMoved-driven cleanup that could cascade-close more).
  local target
  for j = idx - 1, 1, -1 do
    if vim.api.nvim_win_is_valid(stack[j].win) then
      target = stack[j].win; break
    end
  end

  local to_close = stack[idx].win
  if target then pcall(vim.api.nvim_set_current_win, target) end
  pcall(vim.api.nvim_win_close, to_close, false)
end

local function close_all()
  local snapshot = { table.unpack(stack) }
  for _, e in ipairs(snapshot) do
    if vim.api.nvim_win_is_valid(e.win) then
      pcall(vim.api.nvim_win_close, e.win, false)
    end
  end
end

---Look up the context (source uri/position) of the currently-focused
---hover. Used by M.open_from_word to inherit the parent's disambiguation
---context for the next-level symbol lookup.
---@return { uri: string, position: lsp.Position }?
local function current_context()
  local cur = vim.api.nvim_get_current_win()
  for _, e in ipairs(stack) do
    if e.win == cur then return e.context end
  end
  return nil
end

---Find an existing hover window with the given focus_id and focus it.
---`open_floating_preview` stores the focus_id on the floating window as
---`w:<focus_id> = <source_bufnr>`, so we probe for a non-nil value under
---that exact key.
---@param focus_id string
---@return boolean
local function focus_existing(focus_id)
  if not focus_id then return false end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, v = pcall(vim.api.nvim_win_get_var, win, focus_id)
    if ok and v ~= nil and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end

---@param dir 1|-1
local function cycle_hover(dir)
  local wins = {}
  for _, e in ipairs(stack) do
    if vim.api.nvim_win_is_valid(e.win) then table.insert(wins, e.win) end
  end
  if #wins < 2 then return end
  local cur = vim.api.nvim_get_current_win()
  for i, w in ipairs(wins) do
    if w == cur then
      vim.api.nvim_set_current_win(wins[((i - 1 + dir) % #wins) + 1])
      return
    end
  end
  vim.api.nvim_set_current_win(wins[1])
end

-- === Symbol disambiguation ==========================================

-- `locations` is non-standard (the LSP spec only defines singular
-- `location` on WorkspaceSymbol/SymbolInformation), but some servers
-- return arrays anyway. Loose alias keeps the defensive read type-clean.
---@class neonvim.LooseSymbol
---@field name string
---@field location? lsp.Location|{ uri: string }
---@field locations? lsp.Location[]

---Pick the best workspace/symbol result for `word`, using the parent
---hover's context to prefer same-file / same-package matches over
---arbitrary fuzzy hits.
---@param syms neonvim.LooseSymbol[]
---@param word string
---@param context { uri: string, position: lsp.Position }?
---@return neonvim.LooseSymbol?
local function pick_symbol(syms, word, context)
  local parent_uri = context and context.uri
  local parent_dir = parent_uri and parent_uri:match("(.+)/[^/]+$")

  local same_file, same_pkg, exact_anywhere, first
  for _, s in ipairs(syms) do
    if not first then first = s end
    if s.name == word then
      local sloc = s.location or (s.locations and s.locations[1])
      local suri = sloc and sloc.uri
      if parent_uri and suri == parent_uri and not same_file then
        same_file = s
      elseif parent_dir and suri and suri:find(parent_dir, 1, true) and not same_pkg then
        same_pkg = s
      end
      if not exact_anywhere then exact_anywhere = s end
    end
  end
  return same_file or same_pkg or exact_anywhere or first
end

-- === Display =========================================================

---@param result lsp.Hover
---@param source_buf integer
---@param focus_id string
---@param context { uri: string, position: lsp.Position }?
local function display(result, source_buf, focus_id, context)
  local contents = result and result.contents
  if not contents then return end
  local lines = vim.lsp.util.convert_input_to_markdown_lines(contents)
  -- Strip leading/trailing blank lines; an all-blank payload produces
  -- height=0 which nvim_open_win rejects.
  while lines[1] and lines[1]:match("^%s*$") do table.remove(lines, 1) end
  while lines[#lines] and lines[#lines]:match("^%s*$") do table.remove(lines) end
  if vim.tbl_isempty(lines) then return end

  local opts = vim.tbl_extend("force", HOVER_OPTS, {
    focusable = true,
    focus = true,
    focus_id = focus_id,
    -- Disable default close_events. The built-in CursorMoved autocmd on
    -- the source buffer calls close_preview_window with no allow-list,
    -- so any spurious source-CursorMoved during focus transitions kills
    -- the hover. We install our own source-anchored cleanup below.
    close_events = {},
  })

  local ok, bufnr, winid = pcall(vim.lsp.util.open_floating_preview, lines, "markdown", opts)
  if not ok or not bufnr then return end

  if winid and vim.api.nvim_win_is_valid(winid) then
    local h = vim.api.nvim_win_get_height(winid)
    local target = math.min(MIN_HEIGHT, opts.max_height or MIN_HEIGHT)
    if h < target then pcall(vim.api.nvim_win_set_height, winid, target) end
  end

  if winid then
    table.insert(stack, { win = winid, context = context })
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(winid),
      once = true,
      callback = function()
        for i, e in ipairs(stack) do
          if e.win == winid then
            table.remove(stack, i); break
          end
        end
      end,
    })
  end

  vim.keymap.set("n", "K", function() M.open_from_word(source_buf) end, {
    buffer = bufnr, nowait = true, silent = true, desc = "Nested LSP hover",
  })
  vim.keymap.set("n", "<Tab>", function() cycle_hover(1) end, {
    buffer = bufnr, nowait = true, silent = true, desc = "Next hover",
  })
  vim.keymap.set("n", "<S-Tab>", function() cycle_hover(-1) end, {
    buffer = bufnr, nowait = true, silent = true, desc = "Previous hover",
  })
  vim.keymap.set("n", "q", close_latest, {
    buffer = bufnr, nowait = true, silent = true, desc = "Close topmost hover",
  })
  vim.keymap.set("n", "Q", close_all, {
    buffer = bufnr, nowait = true, silent = true, desc = "Close all hovers",
  })

  -- Source-anchored cleanup: close this hover the next time the cursor
  -- actually moves in the source buffer. `once` so each hover's autocmd
  -- self-removes after firing. Deliberately not listening to BufLeave.
  if winid then
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = source_buf,
      once = true,
      callback = function()
        if vim.api.nvim_win_is_valid(winid) then
          pcall(vim.api.nvim_win_close, winid, false)
        end
      end,
    })
  end
end

-- === Public entries =================================================

---Resolve `<cword>` via workspace/symbol and open a hover for the best
---match. Called from inside an already-open hover window.
---@param source_buf integer
function M.open_from_word(source_buf)
  local word = vim.fn.expand("<cword>")
  if word == "" then return end

  generation = generation + 1
  local my_gen = generation
  local parent_ctx = current_context()

  local client = vim.lsp.get_clients({ bufnr = source_buf, method = "workspace/symbol" })[1]
  if not client then
    vim.notify("Nested hover: no LSP supports workspace/symbol", vim.log.levels.INFO)
    return
  end

  client:request("workspace/symbol", { query = word }, function(err, syms)
    if my_gen ~= generation then return end -- superseded by a newer K
    if err or not syms or vim.tbl_isempty(syms) then
      vim.notify("Nested hover: no symbol named '" .. word .. "'", vim.log.levels.INFO)
      return
    end
    local pick = pick_symbol(syms, word, parent_ctx)
    if not pick then return end
    local loc = pick.location or (pick.locations and pick.locations[1])
    if not loc then return end

    local focus_id = ("neonvim.hover:%s:%d:%d"):format(
      loc.uri, loc.range.start.line, loc.range.start.character
    )
    if focus_existing(focus_id) then return end

    client:request("textDocument/hover", {
      textDocument = { uri = loc.uri },
      position = loc.range.start,
    }, function(err2, hover)
      if my_gen ~= generation then return end
      if err2 or not hover or not hover.contents then
        vim.notify("Nested hover: no docs for '" .. word .. "'", vim.log.levels.INFO)
        return
      end
      display(hover, source_buf, focus_id, { uri = loc.uri, position = loc.range.start })
    end, source_buf)
  end, source_buf)
end

---Top-level entry: issue a hover for the cursor position in the current
---buffer. Short-circuits to focus an existing top-level hover if one is
---already open.
function M.open()
  if focus_existing(TOP_FOCUS_ID) then return end

  generation = generation + 1
  local my_gen = generation

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()

  local client = vim.lsp.get_clients({ bufnr = source_buf, method = "textDocument/hover" })[1]
  if not client then
    vim.notify("LSP hover: no client", vim.log.levels.INFO)
    return
  end

  local params = vim.lsp.util.make_position_params(source_win, client.offset_encoding or "utf-16")
  client:request("textDocument/hover", params, function(err, result)
    if my_gen ~= generation then return end
    if err or not result or not result.contents then
      vim.notify("LSP hover: no info", vim.log.levels.INFO)
      return
    end
    display(result, source_buf, TOP_FOCUS_ID, {
      uri = vim.uri_from_bufnr(source_buf),
      position = params.position,
    })
  end, source_buf)
end

return M
