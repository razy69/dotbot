---@brief Mason install commands. Splits "what to install" (declared by the
--- LSP + linter plugins) from "when to install" (explicit user command).
--- Startup emits a WARN for missing tools instead of auto-fetching from the
--- network, so a compromised/MITM'd Mason registry can't silently install
--- packages without consent.
---
--- LSP/linter/formatter plugins call M.register("lsp"|"lint"|"format", specs)
--- at their config time. Users then run `:LspInstall` / `:LintInstall` /
--- `:FormatInstall` to pull missing packages and upgrade any installed ones with
--- newer registry versions. `:MasonStatus` lists what's missing without
--- installing.

local M = {}

local utils = require("utils")

--- Max installs in flight at once. Mason does not throttle: `:install()`-ing
--- every package at the same time saturates the network and makes individual
--- downloads far likelier to stall or fail.
local MAX_CONCURRENT = 4

--- Wall-clock budget (ms) for one install run. The progress toast is posted
--- with `timeout = false`, so a handle that never emits "closed" used to pin
--- it at N/M for the rest of the session.
local INSTALL_TIMEOUT = 10 * 60 * 1000

--- Registry kinds. Each maps to an install command of the same name.
---@type string[]
M.kinds = { "lsp", "lint", "format" }

---@class MasonInstallSpec
---@field pkg string Mason package name
---@field binary string Expected executable on PATH (skip install if present)

---@type table<string, MasonInstallSpec[]>
M._specs = { lsp = {}, lint = {}, format = {} }

--- Merge specs into a kind, de-duplicated by package name. Merging rather than
--- assigning means a second registrant for the same kind can't silently drop
--- the first one's packages.
---@param kind "lsp"|"lint"|"format"
---@param specs MasonInstallSpec[]
function M.register(kind, specs)
  local existing = M._specs[kind] or {}
  local seen = {}
  for _, entry in ipairs(existing) do
    seen[entry.pkg] = true
  end
  for _, entry in ipairs(specs) do
    if not seen[entry.pkg] then
      seen[entry.pkg] = true
      table.insert(existing, entry)
    end
  end
  M._specs[kind] = existing
end

--- Return the subset of specs whose binary isn't on PATH.
---@param specs MasonInstallSpec[]
---@return MasonInstallSpec[]
local function missing(specs)
  local out = {}
  for _, entry in ipairs(specs) do
    if vim.fn.executable(entry.binary) == 0 then
      table.insert(out, entry)
    end
  end
  return out
end

---@param kind "lsp"|"lint"|"format"
function M.warn_missing(kind)
  local gone = missing(M._specs[kind] or {})
  if #gone == 0 then
    return
  end
  local names = {}
  for _, e in ipairs(gone) do
    table.insert(names, e.pkg)
  end
  -- One command per kind; the two-way expression here used to point "format"
  -- at :LintInstall.
  local cmd = (":%s%sInstall"):format(kind:sub(1, 1):upper(), kind:sub(2))
  vim.schedule(function()
    vim.notify(
      ("Mason: %d missing %s tool(s): %s\nRun %s to install."):format(
        #gone, kind, table.concat(names, ", "), cmd
      ),
      vim.log.levels.WARN
    )
  end)
end

--- Return installed packages whose latest registry version differs from the
--- installed one. Both lookups are synchronous in mason v2.
---@param specs MasonInstallSpec[]
---@param registry table mason-registry module
---@return {pkg: table, name: string, latest: string}[]
local function check_updates(specs, registry)
  local updates = {}
  for _, entry in ipairs(specs) do
    local pkg_ok, pkg = pcall(registry.get_package, entry.pkg)
    if pkg_ok and pkg:is_installed() then
      local current = pkg:get_installed_version()
      local latest_ok, latest = pcall(pkg.get_latest_version, pkg)
      if latest_ok and latest and current ~= latest and pkg:is_installable({ version = latest }) then
        table.insert(updates, { pkg = pkg, name = entry.pkg, latest = latest })
      end
    end
  end
  return updates
end

--- Render a fixed-width unicode progress bar: "▰▰▰▱▱▱▱▱▱▱".
---@param done integer
---@param total integer
---@return string
local function progress_bar(done, total)
  local width = 20
  local filled = total > 0 and math.floor(done / total * width + 0.5) or 0
  return string.rep("▰", filled) .. string.rep("▱", width - filled)
end

---@param kind "lsp"|"lint"|"format"
local function install(kind)
  local all_specs = M._specs[kind] or {}
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    vim.notify("Mason: mason-registry not available yet — open a file first to trigger LSP/lint load",
      vim.log.levels.ERROR)
    return
  end
  registry.refresh(function()
    ---@type {pkg: table, name: string, action: "install"|"update", version: string?}[]
    local work = {}
    for _, entry in ipairs(missing(all_specs)) do
      local pkg_ok, pkg = pcall(registry.get_package, entry.pkg)
      if pkg_ok and not pkg:is_installed() then
        table.insert(work, { pkg = pkg, name = entry.pkg, action = "install" })
      end
    end
    for _, u in ipairs(check_updates(all_specs, registry)) do
      table.insert(work, { pkg = u.pkg, name = u.name, action = "update", version = u.latest })
    end

    local total = #work
    if total == 0 then
      vim.schedule(function()
        vim.notify(("Mason %s: nothing to install, all tools up-to-date"):format(kind), vim.log.levels.INFO)
      end)
      return
    end

    local notify_id = "mason-install-" .. kind
    local title = ("Mason %s"):format(kind)
    local done, succeeded = 0, 0
    local failed = {}
    -- Started but never emitted "closed" by the time the clock ran out.
    -- Distinct from `failed`, which is "closed, still not installed".
    local stalled = {}

    local function render_progress(msg)
      vim.notify(
        ("%s  %d/%d  %s"):format(progress_bar(done, total), done, total, msg or ""),
        vim.log.levels.INFO,
        { id = notify_id, title = title, timeout = false }
      )
    end

    local function render_final()
      local problems = {}
      if #failed > 0 then
        problems[#problems + 1] = ("%d failed: %s"):format(#failed, table.concat(failed, ", "))
      end
      if #stalled > 0 then
        problems[#problems + 1] = ("%d did not finish: %s"):format(#stalled, table.concat(stalled, ", "))
      end
      local text
      if #problems == 0 then
        text = ("%s  done  %d/%d"):format(progress_bar(done, total), succeeded, total)
      else
        text = ("%s  done  %d ok, %s"):format(
          progress_bar(done, total), succeeded, table.concat(problems, "; ")
        )
      end
      vim.notify(text, #problems > 0 and vim.log.levels.WARN or vim.log.levels.INFO,
        { id = notify_id, title = title, timeout = 5000 })
    end

    local next_idx, inflight, finalized = 1, 0, false
    local pending = {} ---@type table<string, true> started, not yet closed
    ---@type uv.uv_timer_t?
    local timer = nil

    --- Close out the run exactly once and replace the sticky progress toast
    --- with a terminal one. Called both on the happy path (all handles closed)
    --- and from the wall-clock timer, so the toast can never hang at N/M.
    local function finish_run()
      if finalized then return end
      finalized = true
      utils.close_timer(timer)
      timer = nil
      for name in pairs(pending) do
        table.insert(stalled, name)
      end
      table.sort(stalled)
      pending = {}
      render_final()
    end

    local start_next

    ---@param item {pkg: table, name: string, action: "install"|"update", version: string?}
    local function on_item_closed(item)
      if finalized then return end -- late callback after a timeout
      pending[item.name] = nil
      inflight = inflight - 1
      done = done + 1
      if item.pkg:is_installed() then
        succeeded = succeeded + 1
        local verb = item.action == "install" and "installed" or "updated"
        render_progress(("%s %s"):format(verb, item.name))
      else
        table.insert(failed, item.name)
        render_progress(("failed %s"):format(item.name))
      end
      if done >= total then
        finish_run()
      else
        start_next()
      end
    end

    --- Top the in-flight set back up to MAX_CONCURRENT.
    function start_next()
      while inflight < MAX_CONCURRENT and next_idx <= total do
        local item = work[next_idx]
        next_idx = next_idx + 1
        inflight = inflight + 1
        pending[item.name] = true
        local opts = item.action == "update" and { version = item.version } or nil
        item.pkg:install(opts):once("closed", vim.schedule_wrap(function()
          on_item_closed(item)
        end))
      end
    end

    timer = assert(vim.uv.new_timer())
    timer:start(INSTALL_TIMEOUT, 0, vim.schedule_wrap(finish_run))

    vim.schedule(function()
      render_progress("starting")
    end)

    start_next()
  end)
end

vim.api.nvim_create_user_command("LspInstall", function()
  install("lsp")
end, { desc = "Install missing LSP servers via Mason (opt-in)" })

vim.api.nvim_create_user_command("LintInstall", function()
  install("lint")
end, { desc = "Install missing linters via Mason (opt-in)" })

vim.api.nvim_create_user_command("FormatInstall", function()
  install("format")
end, { desc = "Install missing formatters via Mason (opt-in)" })

vim.api.nvim_create_user_command("MasonStatus", function()
  for _, kind in ipairs(M.kinds) do
    local gone = missing(M._specs[kind])
    if #gone == 0 then
      vim.notify(("Mason %s: all tools present"):format(kind), vim.log.levels.INFO)
    else
      local names = {}
      for _, e in ipairs(gone) do
        table.insert(names, e.pkg)
      end
      vim.notify(("Mason %s missing: %s"):format(kind, table.concat(names, ", ")), vim.log.levels.WARN)
    end
  end
end, { desc = "Report missing Mason-installable LSP servers and linters" })

return M
