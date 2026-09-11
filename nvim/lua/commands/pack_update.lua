---@brief Startup update check for vim.pack-managed plugins (mimics Lazy.nvim).
--- Async `git fetch` for each installed plugin, compares local rev to
--- `origin/HEAD`, then displays a single vim.notify summary. Per-plugin
--- changelogs are cached and accessible via `:PackChangelog [name]`.
--- `:PackUpdate` fetches, filters to plugins with pending updates, and hands
--- off to `vim.pack.update()` in offline mode so only update-available
--- plugins appear in the confirmation buffer.

-- Tunables ------------------------------------------------------------------

--- Minimum seconds between auto-checks. Prevents spamming on every start.
local FREQUENCY = 4 * 60 * 60 -- 4 hours

--- Max commits per plugin shown in the changelog payload.
local LOG_LIMIT = 50

--- Max commit log lines rendered per per-plugin update notification.
local NOTIFY_LOG_LIMIT = 10

--- Wall-clock budget (ms) for the per-plugin `:PackUpdate` notifications.
--- `vim.pack.update()` has no completion callback and a plugin whose checkout
--- fails never emits `PackChanged`, so the notify augroup needs a hard stop.
local NOTIFY_GROUP_TTL = 5 * 60 * 1000

local utils = require("utils")

-- State ---------------------------------------------------------------------

---@class PackUpdateInfo
---@field name string
---@field local_rev string
---@field remote_rev string
---@field log string  Output of `git log --oneline`, may be empty.

---@type table<string, PackUpdateInfo>
local updates = {}

local running = false
-- Set by run_check while a check is active; cleared on success or cancel.
-- Holds the cancellation closure for the current run so :PackCancel and
-- the watchdog can abort only *this* run. The previous design used a
-- module-level `cancelled` bool — a subsequent run_check would reset it
-- to false, letting zombie callbacks from the aborted run proceed against
-- the new run's state. Per-run closures fix that by pinning the cancel
-- flag inside the closure where the callbacks live.
---@type (fun())|nil
local current_cancel = nil

local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "pack-update-check.txt")

-- Helpers -------------------------------------------------------------------

---@return integer unix_timestamp
local function last_check_at()
  local f = io.open(state_file, "r")
  if not f then
    return 0
  end
  local s = f:read("*a") or ""
  f:close()
  return tonumber(s) or 0
end

local function record_check()
  vim.fn.mkdir(vim.fs.dirname(state_file), "p")
  local f = io.open(state_file, "w")
  if f then
    f:write(tostring(os.time()))
    f:close()
  end
end

---@param log string
---@return integer
local function count_commits(log)
  if log == "" then
    return 0
  end
  local n = 1
  for _ in log:gmatch("\n") do
    n = n + 1
  end
  return n
end

-- Progress reporter ---------------------------------------------------------

--- Build a progress reporter that emits LSP-style progress via nvim_echo.
--- Noice (and other notification UIs) render these as a progress bar.
--- Mirrors the mechanism used internally by vim.pack itself.
---@param action string Title shown during progress (e.g. "Checking for updates")
---@return fun(kind: 'begin'|'report'|'end', percent: integer, fmt: string, ...: any)
local function new_progress(action)
  local progress = { kind = "progress", source = "vim.pack", title = "vim.pack" }
  return vim.schedule_wrap(function(kind, percent, fmt, ...)
    progress.status = kind == "end" and "success" or "running"
    progress.percent = percent
    local msg = ("%s %s"):format(action, fmt:format(...))
    -- `history = true` on "end" keeps the final line visible in :messages.
    progress.id = vim.api.nvim_echo({ { msg } }, kind ~= "report", progress)
  end)
end

-- Core check ----------------------------------------------------------------

--- Fetch one plugin and compute update info.
--- Calls `on_done(info_or_nil)` on the main loop.
--- `on_handle(handle, true|false)` is called with each vim.system handle
--- when it's started (true) and when it completes (false), so the caller
--- can kill in-flight subprocesses on cancel/timeout instead of letting
--- them linger after we've given up on their results.
---@param plugin vim.pack.PlugData
---@param on_handle fun(handle: vim.SystemObj, add: boolean)
---@param on_done fun(info: PackUpdateInfo|nil)
local function fetch_one(plugin, on_handle, on_done)
  local cwd = plugin.path
  local local_rev = plugin.rev
  -- A version range (vim.version.range()) pins the plugin to the newest
  -- matching *tag*, which is what vim.pack.update() checks out — not the
  -- branch tip. spec.version holds that range for version-pinned specs and is
  -- nil for branch-tracking ones. (Available with vim.pack.get info=false.)
  local version_range = type(plugin.spec.version) == "table" and plugin.spec.version or nil

  -- Defensive: on fresh install, vim.pack.get() can return plugins whose
  -- working tree doesn't exist yet (install still in progress). Skip them
  -- rather than letting vim.system fail with ENOENT.
  if not cwd or vim.uv.fs_stat(cwd) == nil then
    return on_done(nil)
  end

  local function sys(cmd, cb)
    local handle
    handle = vim.system(cmd, { cwd = cwd, text = true }, vim.schedule_wrap(function(res)
      on_handle(handle, false)
      cb(res)
    end))
    on_handle(handle, true)
  end

  -- Given the resolved remote target rev, compute the changelog and finish.
  local function emit(remote_rev)
    if remote_rev == "" or remote_rev == local_rev then
      return on_done(nil)
    end
    sys({
      "git", "log", "--oneline", "--no-decorate", "--no-color",
      "-n", tostring(LOG_LIMIT),
      local_rev .. ".." .. remote_rev,
    }, function(log_res)
      on_done({
        name = plugin.spec.name,
        local_rev = local_rev,
        remote_rev = remote_rev,
        log = vim.trim(log_res.stdout or ""),
      })
    end)
  end

  sys(
    { "git", "-c", "gc.auto=0", "fetch", "--quiet", "--tags", "--force", "origin" },
    function(fetch_res)
      if fetch_res.code ~= 0 then
        return on_done(nil)
      end
      if version_range then
        -- Target = newest tag satisfying the range. Comparing to origin/HEAD
        -- instead would flag unreleased commits past the latest tag as a
        -- phantom update that vim.pack.update() never applies (it stays on the
        -- pinned tag), leaving a listed-but-never-updated plugin.
        sys({ "git", "tag", "--list" }, function(tag_res)
          if tag_res.code ~= 0 then
            return on_done(nil)
          end
          local best_tag, best_ver
          for raw in (tag_res.stdout or ""):gmatch("[^\n]+") do
            local tag = vim.trim(raw)
            local ok, parsed = pcall(vim.version.parse, tag)
            if ok and parsed and version_range:has(parsed) then
              if not best_ver or parsed > best_ver then
                best_ver, best_tag = parsed, tag
              end
            end
          end
          if not best_tag then
            return on_done(nil)
          end
          -- ^{commit} peels annotated tags to their commit for the comparison.
          sys({ "git", "rev-parse", best_tag .. "^{commit}" }, function(rev_res)
            if rev_res.code ~= 0 then
              return on_done(nil)
            end
            emit(vim.trim(rev_res.stdout or ""))
          end)
        end)
      else
        sys({ "git", "rev-parse", "origin/HEAD" }, function(rev_res)
          if rev_res.code ~= 0 then
            return on_done(nil)
          end
          emit(vim.trim(rev_res.stdout or ""))
        end)
      end
    end
  )
end

--- Run the fetch+compare pipeline across all installed plugins.
--- Refreshes the module-level `updates` cache and invokes `on_complete`.
--- `on_complete(collected, ok)` — `ok = false` means the run never happened
--- (another check was already in flight). It is always invoked exactly once,
--- so callers never sit waiting on a callback that will not arrive.
---@param opts { show_progress?: boolean }
---@param on_complete fun(collected: PackUpdateInfo[], ok: boolean)
local function run_check(opts, on_complete)
  opts = opts or {}
  if running then
    vim.notify(
      "update check already running — this request was dropped, retry when it finishes (:PackCancel aborts it)",
      vim.log.levels.WARN, { title = "vim.pack" }
    )
    -- Signal the failure rather than returning silently: callers used to get
    -- no callback at all, so :PackUpdate warned and then did nothing.
    on_complete({}, false)
    return
  end

  -- vim.pack.get() with info=false skips per-plugin branch/tag lookups.
  local plugins = vim.pack.get(nil, { info = false })
  if #plugins == 0 then
    on_complete({}, true)
    return
  end

  running = true
  updates = {}
  local collected = {}
  -- Per-run state captured by every closure below. Keeping these local
  -- (not module-level) guarantees that callbacks from an aborted run see
  -- their own my_cancelled == true forever, even after a subsequent
  -- run_check has started.
  local my_cancelled = false
  local my_handles = {}
  -- Closure-scoped like the rest of the per-run state. As a module-level
  -- variable, a new run overwrote the handle and stop_watchdog() then closed
  -- whichever watchdog happened to be current — the same cross-run
  -- contamination the `cancelled` flag was moved in here to avoid.
  ---@type uv.uv_timer_t?
  local my_watchdog = nil
  local progress = opts.show_progress and new_progress("Checking for updates") or nil
  local total = #plugins
  local done = 0

  local function stop_watchdog()
    utils.close_timer(my_watchdog)
    my_watchdog = nil
  end

  local function on_handle(handle, add)
    if add then
      my_handles[handle] = true
    else
      my_handles[handle] = nil
    end
  end

  local function cancel()
    if my_cancelled then return end
    my_cancelled = true
    running = false
    current_cancel = nil
    stop_watchdog()
    -- SIGTERM lets `git fetch` unwind its network state; a hung git will
    -- still exit within a few ms. Good enough — we only care that the
    -- subprocess stops competing with the next run_check for resources.
    for handle in pairs(my_handles) do
      pcall(function() handle:kill("sigterm") end)
    end
    my_handles = {}
    if progress then
      pcall(progress, "end", 100, "(cancelled)")
    end
  end

  current_cancel = cancel

  -- Watchdog: force-cancel if check hangs (network timeout, git deadlock).
  my_watchdog = assert(vim.uv.new_timer())
  my_watchdog:start(60000, 0, vim.schedule_wrap(function()
    if my_cancelled then return end
    cancel()
    vim.notify("update check timed out", vim.log.levels.ERROR, { title = "vim.pack" })
  end))

  if progress then
    progress("begin", 0, "(0/%d)", total)
  end

  local function on_one_done(name, info)
    if my_cancelled then return end
    done = done + 1
    if info then
      collected[#collected + 1] = info
      updates[info.name] = info
    end
    if progress then
      local percent = math.floor(100 * done / total)
      if done == total then
        progress("end", 100, "(%d/%d)", done, total)
      else
        progress("report", percent, "(%d/%d) - %s", done, total, name)
      end
    end
    if done == total then
      running = false
      current_cancel = nil
      stop_watchdog()
      record_check()
      on_complete(collected, true)
    end
  end

  -- Bounded pump: spawning one `git fetch` per plugin simultaneously
  -- saturates network/disk across ~40 repos (cf. MAX_CONCURRENT in
  -- commands/mason.lua).
  local FETCH_CONCURRENCY = 4
  local next_idx, inflight = 0, 0
  local pump
  pump = function()
    while inflight < FETCH_CONCURRENCY and next_idx < total and not my_cancelled and done < total do
      next_idx = next_idx + 1
      local p = plugins[next_idx]
      if not p.rev then
        on_one_done(p.spec.name, nil)
      else
        inflight = inflight + 1
        fetch_one(p, on_handle, function(info)
          inflight = inflight - 1
          on_one_done(p.spec.name, info)
          pump()
        end)
      end
    end
  end
  pump()
end

--- Render the default "updates available" summary notification.
---@param collected PackUpdateInfo[]
---@param opts? { notify_when_empty?: boolean }
local function render_summary(collected, opts)
  opts = opts or {}
  if #collected == 0 then
    if opts.notify_when_empty then
      vim.notify("All plugins up to date", vim.log.levels.INFO, { title = "vim.pack" })
    end
    return
  end

  table.sort(collected, function(a, b) return a.name < b.name end)

  local max_name = 0
  for _, u in ipairs(collected) do
    max_name = math.max(max_name, #u.name)
  end

  local lines = {
    ("%d plugin update%s available"):format(#collected, #collected == 1 and "" or "s"),
    "",
  }
  for _, u in ipairs(collected) do
    local pad = string.rep(" ", max_name - #u.name)
    local n = count_commits(u.log)
    lines[#lines + 1] = ("• %s%s  %s..%s  (%d commit%s)"):format(
      u.name, pad,
      u.local_rev:sub(1, 7), u.remote_rev:sub(1, 7),
      n, n == 1 and "" or "s"
    )
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = ":PackChangelog [name] — details · :PackUpdate — apply"

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "vim.pack" })
end

-- Auto-run on startup, throttled --------------------------------------------

-- Defer to VimEnter rather than vim.schedule: the latter fires on the main
-- loop *during* vim.pack.add's async wait, before all plugins are installed,
-- causing ENOENT on not-yet-cloned plugin paths (e.g. first-boot fresh clone).
-- VimEnter fires after all plugin/ files have finished sourcing and every
-- vim.pack.add() has returned.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if os.time() - last_check_at() < FREQUENCY then
      return
    end
    run_check({ show_progress = false }, function(collected, ok)
      if not ok then return end
      render_summary(collected)
    end)
  end,
})

-- User commands -------------------------------------------------------------

vim.api.nvim_create_user_command("PackCheckUpdates", function()
  run_check({ show_progress = true }, function(collected, ok)
    -- Without the `ok` guard a dropped request rendered a bogus
    -- "All plugins up to date" from an empty result set.
    if not ok then return end
    render_summary(collected, { notify_when_empty = true })
  end)
end, { desc = "Check for plugin updates (async, with progress bar)" })

vim.api.nvim_create_user_command("PackChangelog", function(ctx)
  local name = ctx.args
  if name == "" then
    local names = vim.tbl_keys(updates)
    if #names == 0 then
      vim.notify("No pending updates — run :PackCheckUpdates", vim.log.levels.INFO, { title = "vim.pack" })
      return
    end
    table.sort(names)
    local parts = {}
    for _, n in ipairs(names) do
      local u = updates[n]
      parts[#parts + 1] = ("## %s  %s..%s\n\n%s"):format(
        n, u.local_rev:sub(1, 7), u.remote_rev:sub(1, 7), u.log
      )
    end
    vim.notify(table.concat(parts, "\n\n"), vim.log.levels.INFO, { title = "vim.pack" })
    return
  end
  local u = updates[name]
  if not u then
    vim.notify("No pending changes for " .. name, vim.log.levels.WARN, { title = "vim.pack" })
    return
  end
  vim.notify(
    ("## %s  %s..%s\n\n%s"):format(name, u.local_rev:sub(1, 7), u.remote_rev:sub(1, 7), u.log),
    vim.log.levels.INFO,
    { title = "vim.pack" }
  )
end, {
  desc = "Show changelog for plugins with pending updates",
  nargs = "?",
  complete = function()
    local names = vim.tbl_keys(updates)
    table.sort(names)
    return names
  end,
})

--- :PackUpdate[!] — update only plugins with pending changes.
---   - `:PackUpdate`  → auto-apply (no confirm buffer). Two progress phases:
---      "Checking for updates" (ours) → "Applying updates" (vim.pack's, same
---      nvim_echo kind=progress mechanism). `offline = true` reuses our fetch.
---   - `:PackUpdate!` → open vim.pack's confirm buffer filtered to pending
---      plugins, so you can deselect individual ones before applying.
---
--- Per-plugin progress notifications: we listen for `PackChangedPre` (fired
--- just before each plugin's checkout) and emit "Updating package N/M: name
--- from a..b" plus the cached commit log. Cleanup is done on the matching
--- `PackChanged` event — or on the next `:PackUpdate` via `clear = true`.
vim.api.nvim_create_user_command("PackUpdate", function(ctx)
  run_check({ show_progress = true }, function(collected, ok)
    if not ok then return end -- request dropped; run_check already warned
    if #collected == 0 then
      vim.notify("All plugins up to date", vim.log.levels.INFO, { title = "vim.pack" })
      return
    end

    local names = {}
    local target_set = {}
    for _, u in ipairs(collected) do
      names[#names + 1] = u.name
      target_set[u.name] = true
    end
    table.sort(names)

    -- Snapshot changelog details: PackChangedPre fires async during
    -- vim.pack.update(), after the `updates` cache is cleared below, so the
    -- callback must not depend on that shared table.
    local details = {}
    for _, u in ipairs(collected) do
      details[u.name] = u
    end

    local total = #names
    local started, finished = 0, 0
    local group = utils.augroup("pack_update_notify")
    local group_alive = true
    ---@type uv.uv_timer_t?
    local group_timer = nil

    --- Drop the notify augroup (and its backstop timer) exactly once. The old
    --- code only deleted it on `finished >= total`, so a plugin that failed to
    --- update — no PackChanged event — left the autocmds live until the next
    --- :PackUpdate happened to clear the group.
    local function teardown()
      if not group_alive then return end
      group_alive = false
      utils.close_timer(group_timer)
      group_timer = nil
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end

    vim.api.nvim_create_autocmd("PackChangedPre", {
      group = group,
      callback = function(ev)
        if ev.data.kind ~= "update" or not target_set[ev.data.spec.name] then
          return
        end
        started = started + 1
        local idx = started
        local name = ev.data.spec.name
        local u = details[name]

        -- Defer UI work: PackChangedPre fires inside vim.pack's async
        -- coroutine, and vim.notify touches the UI. vim.schedule takes us
        -- back to the main loop.
        vim.schedule(function()
          local lines = {}
          if u then
            lines[#lines + 1] = ("Updating package %d/%d: %s from %s to %s"):format(
              idx, total, name, u.local_rev:sub(1, 7), u.remote_rev:sub(1, 7)
            )
          else
            lines[#lines + 1] = ("Updating package %d/%d: %s"):format(idx, total, name)
          end
          if u and u.log ~= "" then
            local shown, total_commits = 0, count_commits(u.log)
            for line in u.log:gmatch("[^\n]+") do
              shown = shown + 1
              if shown > NOTIFY_LOG_LIMIT then
                lines[#lines + 1] = ("  … (%d more)"):format(total_commits - NOTIFY_LOG_LIMIT)
                break
              end
              lines[#lines + 1] = "• " .. line
            end
          end
          vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "vim.pack" })
        end)
      end,
    })

    vim.api.nvim_create_autocmd("PackChanged", {
      group = group,
      callback = function(ev)
        if not target_set[ev.data.spec.name] then
          return
        end
        finished = finished + 1
        if finished >= total then
          vim.schedule(teardown)
        end
      end,
    })

    -- Backstop for the partial-failure path: vim.pack.update() reports no
    -- completion, so tear the group down on a wall clock and say which
    -- plugins never reported back.
    group_timer = assert(vim.uv.new_timer())
    group_timer:start(NOTIFY_GROUP_TTL, 0, vim.schedule_wrap(function()
      if not group_alive then return end
      if finished < total then
        vim.notify(
          ("Update notifications stopped: only %d/%d plugin%s reported done"):format(
            finished, total, total == 1 and "" or "s"
          ),
          vim.log.levels.WARN, { title = "vim.pack" }
        )
      end
      teardown()
    end))

    -- force = true skips confirm buffer; vim.pack emits "Applying updates"
    -- progress via the same nvim_echo mechanism as our "Checking for updates".
    local upd_ok, upd_err = pcall(vim.pack.update, names, { offline = true, force = not ctx.bang })
    if not upd_ok then
      teardown()
      vim.notify("update failed: " .. tostring(upd_err), vim.log.levels.ERROR, { title = "vim.pack" })
      return
    end

    -- Clear stale changelog entries immediately — the updates are now in
    -- flight and these local_rev/remote_rev comparisons are outdated.
    -- Cannot rely on PackChanged events (they may not fire with the
    -- expected kind/name filter in all vim.pack versions).
    for _, name in ipairs(names) do
      updates[name] = nil
    end
    vim.notify(
      ("Updating %d plugin%s"):format(total, total == 1 and "" or "s"),
      vim.log.levels.INFO,
      { title = "vim.pack" }
    )
  end)
end, {
  bang = true,
  desc = "Update pending plugins (bang = open confirm buffer for selective apply)",
})

vim.api.nvim_create_user_command("PackCancel", function()
  if current_cancel then
    current_cancel()
    vim.notify("update check cancelled", vim.log.levels.INFO, { title = "vim.pack" })
  else
    vim.notify("No update check running", vim.log.levels.INFO, { title = "vim.pack" })
  end
end, { desc = "Cancel running pack update check" })

vim.api.nvim_create_user_command("PackClean", function()
  -- Build set of expected pack names from registered specs. Each src entry
  -- may be a URL string or a `{ src = ..., name = ... }` table — the name
  -- field, when present, overrides the URL-derived name (vim.pack installs
  -- the plugin under that name). Without this, specs like catppuccin that
  -- pin `name = "catppuccin"` on a `.../nvim` URL get flagged as orphans
  -- because the URL tail ("nvim") doesn't match the installed name.
  local expected = {}
  for _, spec in pairs(plugin._specs) do
    local src = spec.src
    if type(src) == "string" then src = { src } end
    for _, s in ipairs(src) do
      local name
      if type(s) == "table" then
        ---@cast s {name?:string, src?:string}
        name = s.name or (type(s.src) == "string" and s.src:match("[^/]+$") or nil)
      elseif type(s) == "string" then
        name = s:match("[^/]+$")
      end
      if name then
        expected[name] = true
      end
    end
  end

  -- Compare against installed packs
  local installed = vim.pack.get(nil, { info = false })
  local orphan_names = {}
  for _, pkg in ipairs(installed) do
    if not expected[pkg.spec.name] then
      table.insert(orphan_names, pkg.spec.name)
    end
  end

  if #orphan_names == 0 then
    vim.notify("No orphaned plugins found", vim.log.levels.INFO, { title = "vim.pack" })
    return
  end

  table.sort(orphan_names)

  vim.ui.select({ "Yes", "No" }, {
    prompt = ("Remove %d orphaned plugin%s?\n  %s"):format(
      #orphan_names, #orphan_names == 1 and "" or "s", table.concat(orphan_names, ", ")
    ),
  }, function(choice)
    if choice ~= "Yes" then return end
    -- vim.pack.del handles both the on-disk removal and the lockfile
    -- update. The previous implementation used vim.fn.delete() directly,
    -- which left stale entries in nvim-pack-lock.json and caused vim.pack
    -- to "re-discover" the plugin on the next startup.
    local ok, err = pcall(vim.pack.del, orphan_names)
    if not ok then
      vim.notify("del failed: " .. tostring(err), vim.log.levels.ERROR, { title = "vim.pack" })
      return
    end
    vim.notify(
      ("Removed %d plugin%s: %s"):format(
        #orphan_names, #orphan_names == 1 and "" or "s", table.concat(orphan_names, ", ")
      ),
      vim.log.levels.INFO, { title = "vim.pack" }
    )
  end)
end, { desc = "Remove orphaned plugins not in current specs" })
