---@brief Simulated workspace diagnostics for LSP servers without
--- `workspace/diagnostic` (LSP 3.17) support.
---
--- Walks the project, opens each matching file as a hidden loaded buffer,
--- which triggers the standard FileType → vim.lsp.enable attach path and
--- causes the server to publish diagnostics. Buffers stay loaded so the
--- server keeps the diagnostics live; otherwise didClose typically revokes
--- them.
---
--- Hard-bounded so it cannot crash the editor on large monorepos:
--- file-count cascade (full → package → dir → refuse), per-file size cap,
--- cumulative byte cap, binary sniff, server backpressure, on_key pause.
--- Servers opt in by setting `workspace_scan = true` on their lsp/<name>.lua
--- config; the LspAttach handler in plugin/03-lsp.lua dispatches here.

local M = {}

-- Tunables ----------------------------------------------------------------

local MAX_FILES_FULL = 1500
local MAX_FILES_PACKAGE = 800
local MAX_FILES_DIR = 200
local MAX_FILES_HARD_REFUSE = 15000
local MAX_BYTES_TOTAL = 200 * 1024 * 1024
local MAX_BYTES_FILE = 256 * 1024
local BATCH_FILES = 4
local BATCH_INTERVAL_MS = 80
local IDLE_RESUME_MS = 3000
local MAX_PENDING = 50
local DEFER_START_MS = 2000
local MAX_DELTA = 100

-- Markers used to find the package containing the current file when the
-- repo is too big to scan whole. Order matters: closer markers win because
-- vim.fs.find walks up from the current file's dir.
local PACKAGE_MARKERS = {
  "go.mod", "Cargo.toml", "package.json", "pyproject.toml",
  "setup.py", "Pipfile", "pom.xml", "build.gradle",
  "mix.exs", "composer.json", "Gemfile", "CMakeLists.txt",
}

-- Directory names to skip in the non-git fs_walk fallback.
local DIR_IGNORE = {
  ["node_modules"] = true,
  [".venv"] = true,
  ["__pycache__"] = true,
  ["target"] = true,
  ["dist"] = true,
  ["build"] = true,
  [".next"] = true,
  [".git"] = true,
  ["vendor"] = true,
  [".cache"] = true,
  [".tox"] = true,
  ["coverage"] = true,
}

-- State -------------------------------------------------------------------

---@class workspace_diag.Entry
---@field path string
---@field size integer
---@field mtime integer

---@class workspace_diag.State
---@field queues table<integer, workspace_diag.Entry[]>  per-client work queues
---@field loaded table<string, integer>                  path -> mtime of files we opened (cumulative, drives dedup + delta())
---@field bytes_loaded integer                           bytes opened by the current scan
---@field files_loaded integer                           files opened by the current scan
---@field timer uv.uv_timer_t?
---@field paused boolean
---@field on_key_ns integer?
---@field resume_timer uv.uv_timer_t?
---@field scope string?                                  "full"|"package"|"dir"
---@field total_queued integer                           snapshot of queue size at scan start (for progress %)
---@field last_progress_pct integer                      last percentage we emitted, to throttle notifies
local state = {
  queues = {},
  loaded = {},
  bytes_loaded = 0,
  files_loaded = 0,
  timer = nil,
  paused = false,
  on_key_ns = nil,
  resume_timer = nil,
  scope = nil,
  total_queued = 0,
  last_progress_pct = -1,
}

local PROGRESS_ID = "neonvim.workspace_diagnostics"
local DONE_ID = "neonvim.workspace_diagnostics.done"
local PROGRESS_STEP = 10 -- emit a progress notify every N% completed

-- Helpers -----------------------------------------------------------------

local function notify(msg, level)
  vim.notify("workspace_diagnostics: " .. msg, level or vim.log.levels.INFO)
end

-- Replace-style notify: backends that support `opts.id` (snacks.notifier,
-- nvim-notify with replace) collapse repeated calls into a single updating
-- notification. Backends that don't support id silently ignore it, which
-- means we get N separate notifications — annoying but not broken, hence
-- the PROGRESS_STEP throttle.
local function progress_notify(msg, level)
  vim.notify(
    "workspace_diagnostics: " .. msg,
    level or vim.log.levels.INFO,
    { id = PROGRESS_ID, title = "Workspace diagnostics", replace = PROGRESS_ID }
  )
end

-- Dismiss the progress toast (if the notifier supports it). Called when
-- the scan reaches a terminal state so the dedicated done/cancel toast
-- below isn't drowned out by a stale in-progress one.
local function hide_progress()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.notifier and snacks.notifier.hide then
    pcall(snacks.notifier.hide, PROGRESS_ID)
  end
end

-- Terminal notify: a fresh toast (separate id) that doesn't get clobbered
-- by snacks' replace logic and stays visible for its own timeout window.
-- Used for completion, abort, and the memory-cap path.
local function done_notify(msg, level)
  hide_progress()
  vim.notify(
    "workspace_diagnostics: " .. msg,
    level or vim.log.levels.INFO,
    { id = DONE_ID, title = "Workspace diagnostics", timeout = 5000 }
  )
end

-- Render a 20-cell ASCII progress bar. Used in the periodic progress
-- notify so even backends without rich progress UI show a visual bar.
local function render_bar(pct)
  local width = 20
  local filled = math.floor(pct * width / 100 + 0.5)
  return "[" .. string.rep("█", filled) .. string.rep("░", width - filled) .. "]"
end

local close_timer = require("utils").close_timer

local function get_root()
  local ok, snacks_git = pcall(require, "snacks.git")
  if ok then
    local r = snacks_git.get_root()
    if r and r ~= "" then return r end
  end
  return vim.uv.cwd() or vim.fn.getcwd()
end

-- Walk up from start_dir to find the nearest package marker, bounded by
-- repo_root so we never escape the repo.
local function find_package_dir(start_path, repo_root)
  if not start_path or start_path == "" then return nil end
  local found = vim.fs.find(PACKAGE_MARKERS, {
    upward = true,
    path = vim.fs.dirname(start_path),
    stop = vim.fs.dirname(repo_root),
    limit = 1,
  })
  if found and found[1] then
    return vim.fs.dirname(found[1])
  end
  return nil
end

local function git_ls_files(root)
  local result = vim.system(
    { "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard" },
    { text = true }
  ):wait(5000)
  if result.code ~= 0 or not result.stdout then return nil end
  local files = {}
  for rel in result.stdout:gmatch("[^\r\n]+") do
    if rel ~= "" then
      files[#files + 1] = vim.fs.joinpath(root, rel)
    end
  end
  return files
end

-- Recursive directory walk with hardcoded ignore list. Used only outside
-- git repos. Bounded by depth so we never recurse into deep symlinks.
local function fs_walk(root)
  local files = {}
  local function walk(dir, depth)
    if depth <= 0 then return end
    local h = vim.uv.fs_scandir(dir)
    if not h then return end
    while true do
      local name, t = vim.uv.fs_scandir_next(h)
      if not name then break end
      if not DIR_IGNORE[name] and not name:match("^%.") then
        local p = vim.fs.joinpath(dir, name)
        if t == "file" then
          files[#files + 1] = p
        elseif t == "directory" then
          walk(p, depth - 1)
        end
      end
    end
  end
  walk(root, 6)
  return files
end

-- Cascade: full → package → dir → refuse. Returns (scope, files, error).
local function pick_scope(repo_root, current_path)
  local home = vim.uv.os_homedir() or ""
  if repo_root == home or repo_root == "/" or repo_root == "" then
    return nil, nil, "refused (root is " .. repo_root .. ")"
  end

  local all = git_ls_files(repo_root)
  if not all then all = fs_walk(repo_root) end
  if not all or #all == 0 then return nil, nil, "no files enumerated" end

  if #all > MAX_FILES_HARD_REFUSE then
    return nil, nil, ("refused (%d files, hard cap %d)"):format(#all, MAX_FILES_HARD_REFUSE)
  end

  if #all <= MAX_FILES_FULL then
    return "full", all, nil
  end

  if current_path and current_path ~= "" then
    local pkg = find_package_dir(current_path, repo_root)
    if pkg then
      local in_pkg = {}
      local prefix = pkg .. "/"
      for _, p in ipairs(all) do
        if vim.startswith(p, prefix) then in_pkg[#in_pkg + 1] = p end
      end
      if #in_pkg > 0 and #in_pkg <= MAX_FILES_PACKAGE then
        return "package:" .. pkg, in_pkg, nil
      end
    end

    local dir = vim.fs.dirname(current_path)
    if dir and dir ~= "" then
      local in_dir = {}
      local prefix = dir .. "/"
      for _, p in ipairs(all) do
        if vim.startswith(p, prefix) then in_dir[#in_dir + 1] = p end
      end
      if #in_dir > 0 and #in_dir <= MAX_FILES_DIR then
        return "dir:" .. dir, in_dir, nil
      end
    end
  end

  return nil, nil, ("scope too large (%d files, no package fits)"):format(#all)
end

-- Build per-client queue: filter by filetype, size, and a quick binary
-- sniff so we don't ship `.png` data through LSP.
local function filter_for_client(client, files)
  local filetypes = (client.config and client.config.filetypes) or {}
  if #filetypes == 0 then return {} end
  local ftset = {}
  for _, ft in ipairs(filetypes) do ftset[ft] = true end

  local out = {}
  for _, path in ipairs(files) do
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == "file" and stat.size > 0 and stat.size <= MAX_BYTES_FILE then
      local ft = vim.filetype.match({ filename = path })
      if ft and ftset[ft] then
        local fd = vim.uv.fs_open(path, "r", 438)
        if fd then
          local data = vim.uv.fs_read(fd, 1024, 0)
          vim.uv.fs_close(fd)
          if data and not data:find("\0", 1, true) then
            out[#out + 1] = { path = path, size = stat.size, mtime = stat.mtime.sec }
          end
        end
      end
    end
  end
  return out
end

local function pending_count(client)
  local n = 0
  for _ in pairs(client.requests or {}) do n = n + 1 end
  return n
end

-- Core: open one file as a hidden loaded buffer. Returns true if we
-- actually loaded something new, false if the buffer was already loaded
-- or load failed.
local function open_file(path, mtime)
  if state.loaded[path] then return false end
  local existing = vim.fn.bufnr(path)
  if existing ~= -1 and vim.api.nvim_buf_is_loaded(existing) then
    state.loaded[path] = mtime
    return false
  end
  local ok, bufnr = pcall(vim.fn.bufadd, path)
  if not ok or bufnr == 0 then return false end
  -- Set buffer-local options before bufload so BufReadPost handlers see them.
  pcall(function() vim.bo[bufnr].buflisted = false end)
  pcall(function() vim.bo[bufnr].bufhidden = "hide" end)
  local load_ok = pcall(vim.fn.bufload, bufnr)
  if not load_ok then return false end
  state.loaded[path] = mtime
  return true
end

-- Drain BATCH_FILES per tick across all clients, respecting backpressure
-- and the global byte cap. Cancels itself when all queues are empty.
local function tick()
  if state.paused then return end

  local processed = 0
  for client_id, q in pairs(state.queues) do
    if processed >= BATCH_FILES then break end
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      state.queues[client_id] = nil
    elseif pending_count(client) <= MAX_PENDING then
      while #q > 0 and processed < BATCH_FILES do
        local entry = table.remove(q, 1)
        if state.bytes_loaded + entry.size > MAX_BYTES_TOTAL then
          M.cancel()
          done_notify(
            ("hit memory cap (%d MB) · %d files loaded · scan stopped"):format(
              math.floor(MAX_BYTES_TOTAL / 1024 / 1024), state.files_loaded
            ),
            vim.log.levels.WARN
          )
          return
        end
        if open_file(entry.path, entry.mtime) then
          state.bytes_loaded = state.bytes_loaded + entry.size
          state.files_loaded = state.files_loaded + 1
        end
        processed = processed + 1
      end
    end
  end

  -- Drop empty queues; if none remain, we're done.
  local any_left = false
  for client_id, q in pairs(state.queues) do
    if #q > 0 then
      any_left = true
    else
      state.queues[client_id] = nil
    end
  end

  if not any_left then
    -- Files/bytes opened by *this* scan, not the session-cumulative
    -- registry — the latter made repeat scans report inflated figures.
    local count = state.files_loaded
    M.cancel()
    done_notify(
      ("scan complete · %s 100%% · %d files · %.1f MB · scope=%s"):format(
        render_bar(100), count, state.bytes_loaded / 1024 / 1024, state.scope or "?"
      )
    )
    return
  end

  -- Throttled progress: only emit when we cross a PROGRESS_STEP boundary
  -- so the notifier isn't hammered every batch. Falls through silently
  -- when total_queued is 0 (shouldn't happen post-scan-start, but safe).
  if state.total_queued > 0 then
    local done = state.total_queued
    for _, q in pairs(state.queues) do done = done - #q end
    local pct = math.floor(done * 100 / state.total_queued)
    if pct >= state.last_progress_pct + PROGRESS_STEP then
      state.last_progress_pct = pct - (pct % PROGRESS_STEP)
      progress_notify(
        ("%s %d%% · %d/%d files · %.1f MB"):format(
          render_bar(pct), pct, done, state.total_queued, state.bytes_loaded / 1024 / 1024
        )
      )
    end
  end
end

-- Pause as soon as the user touches any key; resume after IDLE_RESUME_MS.
local function install_keypause()
  if state.on_key_ns then return end
  state.on_key_ns = vim.api.nvim_create_namespace("workspace_diagnostics_pause")
  -- One timer for the lifetime of the scan, simply restarted on each
  -- keystroke. The previous version allocated and closed a fresh libuv
  -- handle per keypress, which is pure churn while typing.
  state.resume_timer = vim.uv.new_timer()
  vim.on_key(function()
    state.paused = true
    local t = state.resume_timer
    if not t or t:is_closing() then return end
    t:stop()
    t:start(IDLE_RESUME_MS, 0, vim.schedule_wrap(function()
      state.paused = false
    end))
  end, state.on_key_ns)
end

local function uninstall_keypause()
  if state.on_key_ns then
    vim.on_key(nil, state.on_key_ns)
    state.on_key_ns = nil
  end
  close_timer(state.resume_timer)
  state.resume_timer = nil
  -- Must clear the flag: on_key pauses on *any* keypress, so a scan that
  -- completes or aborts while paused would otherwise leave paused=true with
  -- no resume timer left to reset it — and the next scan's tick() would
  -- return immediately, making no progress until the user happened to
  -- press a key.
  state.paused = false
end

-- Public ------------------------------------------------------------------

--- Schedule a deferred scan for one client (called from LspAttach).
--- Scan starts after DEFER_START_MS so it never competes with startup.
---@param client_id integer
---@param bufnr integer
function M.schedule(client_id, bufnr)
  vim.defer_fn(function()
    M.scan({ client_id = client_id, bufnr = bufnr })
  end, DEFER_START_MS)
end

--- Run a scan synchronously (queue immediately, timer drives the rest).
--- Adds to existing queues if already running.
---@param opts? { client_id?: integer, bufnr?: integer }
function M.scan(opts)
  opts = opts or {}

  local clients
  if opts.client_id then
    local c = vim.lsp.get_client_by_id(opts.client_id)
    clients = c and { c } or {}
  else
    clients = vim.tbl_filter(function(c)
      local cfg = vim.lsp.config[c.name] or {}
      return not c:supports_method("workspace/diagnostic") and cfg.workspace_scan == true
    end, vim.lsp.get_clients())
  end
  if #clients == 0 then return end

  local repo_root = get_root()
  local current_buf = opts.bufnr or vim.api.nvim_get_current_buf()
  local current_path = ""
  if vim.api.nvim_buf_is_valid(current_buf) then
    current_path = vim.api.nvim_buf_get_name(current_buf)
  end

  local scope, files, err = pick_scope(repo_root, current_path)
  if not scope then
    notify(err or "no scope", vim.log.levels.WARN)
    return
  end

  -- Build the per-client entry lists up front but keep them off `state`
  -- until we know there is real work. Committing the scope (and empty
  -- queues) before the total_queued check made
  -- :LspWorkspaceScanStatus report a scope for a scan that never ran.
  local queued = {}
  local total_queued = 0
  for _, client in ipairs(clients) do
    local entries = filter_for_client(client, files)
    if #entries > 0 then
      queued[client.id] = entries
      total_queued = total_queued + #entries
    end
  end

  if total_queued == 0 then
    notify(("scope=%s but no files matched any client filetypes"):format(scope))
    return
  end

  -- Reset the per-scan accumulators, but only for a genuinely fresh scan —
  -- scan() is re-entrant and a second call while work is in flight just
  -- adds to the running totals. These were previously never reset, so
  -- bytes grew for the whole session until every scan tripped
  -- MAX_BYTES_TOTAL and reported "hit memory cap" with a session-cumulative
  -- MB figure. `state.loaded` deliberately stays cumulative: it is the
  -- dedup registry and the set M.delta() re-stats, so clearing it would
  -- make us forget buffers a previous scan opened.
  local in_flight = false
  for _, q in pairs(state.queues) do
    if #q > 0 then
      in_flight = true
      break
    end
  end
  if not state.timer and not in_flight then
    state.bytes_loaded = 0
    state.files_loaded = 0
  end

  state.scope = scope
  for client_id, entries in pairs(queued) do
    state.queues[client_id] = state.queues[client_id] or {}
    vim.list_extend(state.queues[client_id], entries)
  end

  -- Snapshot total for progress %; account for any queue carried from a
  -- prior in-flight scan (re-entrant scan call adds work).
  local pending_already = 0
  for _, q in pairs(state.queues) do pending_already = pending_already + #q end
  state.total_queued = pending_already
  state.last_progress_pct = -1

  local client_names = {}
  for _, c in ipairs(clients) do client_names[#client_names + 1] = c.name end
  progress_notify(
    ("starting scan · %s 0%% · %d files · scope=%s · clients=%s"):format(
      render_bar(0), total_queued, scope, table.concat(client_names, ",")
    )
  )

  install_keypause()
  if not state.timer then
    state.timer = vim.uv.new_timer()
    if state.timer then
      state.timer:start(BATCH_INTERVAL_MS, BATCH_INTERVAL_MS, vim.schedule_wrap(tick))
    end
  end
end

--- Cancel the scan; already-loaded buffers stay loaded.
function M.cancel()
  close_timer(state.timer)
  state.timer = nil
  uninstall_keypause()
end

--- User-initiated cancel (emits a notify so the user sees the scan stopped).
--- Internal callers (completion, memory cap) use M.cancel() directly to
--- avoid double-notifying after a status message.
function M.abort()
  local pending = 0
  for _, q in pairs(state.queues) do pending = pending + #q end
  M.cancel()
  state.queues = {}
  if pending > 0 then
    done_notify(
      ("scan cancelled · %d files left unprocessed · %d already loaded"):format(
        pending, vim.tbl_count(state.loaded)
      ),
      vim.log.levels.WARN
    )
  end
end

--- Drop a client's queue (call from LspDetach).
---@param client_id integer
function M.detach(client_id)
  state.queues[client_id] = nil
end

--- Re-stat loaded paths and trigger a reload for those whose mtime moved.
--- Bounded to MAX_DELTA *examined* paths per call. The counter used to be
--- incremented only inside the changed-mtime branch, which capped reloads
--- but not the fs_stat() walk — so every call synchronously stat'ed all of
--- state.loaded (up to MAX_FILES_FULL paths), and the caller is a
--- FocusGained autocmd, i.e. every alt-tab back into the editor.
function M.delta()
  if vim.tbl_isempty(state.loaded) then return end
  local checked = 0
  for path, prev_mtime in pairs(state.loaded) do
    if checked >= MAX_DELTA then break end
    checked = checked + 1
    local stat = vim.uv.fs_stat(path)
    if stat and stat.mtime.sec ~= prev_mtime then
      local bufnr = vim.fn.bufnr(path)
      if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
        -- :checktime triggers FileChangedShell + reload, which fires
        -- BufReadPost → didChange so the LSP re-analyses.
        pcall(vim.api.nvim_buf_call, bufnr, function()
          vim.cmd("checktime")
        end)
        state.loaded[path] = stat.mtime.sec
      else
        -- Buffer was wiped externally; forget it.
        state.loaded[path] = nil
      end
    end
  end
end

--- Diagnostic info for :LspWorkspaceScan stats / debugging.
---@return { scope: string?, loaded: integer, pending: integer, bytes_loaded: integer, paused: boolean, running: boolean }
function M.stats()
  local pending = 0
  for _, q in pairs(state.queues) do pending = pending + #q end
  return {
    scope = state.scope,
    loaded = vim.tbl_count(state.loaded),
    pending = pending,
    bytes_loaded = state.bytes_loaded,
    paused = state.paused,
    running = state.timer ~= nil,
  }
end

return M
