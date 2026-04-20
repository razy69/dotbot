---@brief Lightweight declarative plugin manager built on top of vim.pack.
--- Provides lazy-loading via event/ft/cmd/keys triggers, dependency resolution,
--- and automatic post-install/update build hooks.

local M = {}

--- Augroup for all lazy-loading autocmds and build dispatch
local augroup = vim.api.nvim_create_augroup("plugin_lazy", { clear = true })

--- Shared event constants for lazy-loading triggers
M.LazyFile = { "BufReadPost", "BufNewFile", "BufWritePre" }

--- Valid fields in a PluginSpec (used for typo detection)
local known_fields = {
  "name", "disabled", "lazy", "src", "version", "deps",
  "event", "ft", "cmd", "keys", "build", "config",
}

---@class PluginKeySpec
---@field [1] string Left-hand side of the keymap
---@field desc? string Keymap description (shown in which-key)
---@field mode? string|string[] Vim mode(s), defaults to "n"

---@class PluginBuildInfo
---@field path string Filesystem path to the plugin directory
---@field name string Pack name (last segment of the git URL, e.g. "blink.cmp")
---@field kind string "install" or "update"

---@class PluginSpec
---@field name string Unique identifier, must match the registry key
---@field disabled? boolean Disable plugin
---@field lazy? boolean Defer vim.pack.add + config to vim.schedule
---@field src string|table<string|table> Git URL(s) for vim.pack.add
---@field version? string Semver constraint passed to vim.pack
---@field deps? string[] Names of specs that must be loaded first
---@field event? string[] Neovim events that trigger loading (e.g. "BufReadPost")
---@field ft? string[] Filetypes that trigger loading (e.g. "go", "lua")
---@field cmd? string[] Ex commands that trigger loading (e.g. "Neotree")
---@field keys? PluginKeySpec[] Keymaps that trigger loading
---@field build? fun(info: PluginBuildInfo) Called after install/update via PackChanged
---@field config? fun() Called after the plugin is loaded

---@type table<string, PluginSpec>
M._specs = {}

--- Tracks which plugins have been fully loaded (config executed)
---@type table<string, boolean>
M._loaded = {}

--- Guards against circular dependency loops during loading
---@type table<string, boolean>
M._loading = {}

--- Ordered stack of in-flight loads; used to report the cycle path when a
--- circular dependency is detected. Mirrors M._loading but ordered.
---@type string[]
M._load_stack = {}

--- Cleanup functions to remove stale triggers after a plugin loads
---@type table<string, fun()[]>
M._cleanup = {}

-- Registry ------------------------------------------------------------------

--- Check if a plugin is registered and not disabled.
---@param name string Plugin name
---@return boolean
function M.is_enabled(name)
  local spec = M._specs[name]
  return spec ~= nil and not spec.disabled
end

-- Timing instrumentation ----------------------------------------------------

--- Monotonic clock at module load. All timings are measured in ms relative
--- to this reference. Set at require() time, which happens early in init.lua
--- (before any plugin/ files are sourced), so it approximates startup t0.
M._t0 = vim.uv.hrtime()

--- Milestone timestamps in ms since M._t0. Filled in by VimEnter/UIEnter.
--- @type { vim_enter?: number, ui_enter?: number }
M.milestones = {}

---@class PluginTiming
---@field name string Plugin name
---@field at_ms number Time of load start (ms since M._t0)
---@field dur_ms number vim.pack.add + cleanup + config, end-to-end
---@field config_ms number Just spec.config() duration
---@field trigger string Why the plugin loaded: "eager" | "dep:<parent>" |
---   "event:<evt>" | "ft:<filetype>" | "cmd:<cmd>" | "keys:<lhs>" | "api"

--- All completed plugin loads in chronological order.
---@type PluginTiming[]
M.timings = {}

-- Record key milestones.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    M.milestones.vim_enter = (vim.uv.hrtime() - M._t0) / 1e6
  end,
})
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    M.milestones.ui_enter = (vim.uv.hrtime() - M._t0) / 1e6
  end,
})

-- Loader --------------------------------------------------------------------

--- Convert a PluginSpec's src field into the table format expected by vim.pack.add().
--- Handles single strings, arrays of strings, and mixed arrays with table entries.
---@param spec PluginSpec
---@return table pack_specs Array suitable for vim.pack.add()
local function build_pack_specs(spec)
  local src = spec.src
  if type(src) == "string" then
    src = { src }
  end
  local pack_specs = {}
  for _, s in ipairs(src) do
    table.insert(pack_specs, s)
  end
  -- Apply top-level version constraint to a single string source
  if spec.version and #pack_specs == 1 and type(pack_specs[1]) == "string" then
    pack_specs[1] = { src = pack_specs[1], version = spec.version }
  end
  return pack_specs
end

--- Core load logic: install packs, run cleanup, execute config.
---@param name string Plugin name
---@param spec PluginSpec Plugin specification
---@param trigger? string Why this load was triggered (for profiling)
local function do_load(name, spec, trigger)
  local t_begin = vim.uv.hrtime()

  local pack_specs = build_pack_specs(spec)
  local ok, err = pcall(vim.pack.add, pack_specs, { confirm = false, load = true })
  if not ok then
    vim.notify("plugin " .. name .. ": failed to load\n" .. tostring(err), vim.log.levels.WARN)
    M._loading[name] = nil
    return
  end

  -- Remove stale placeholder triggers (commands, keymaps, autocmds)
  if M._cleanup[name] then
    for _, fn in ipairs(M._cleanup[name]) do
      local c_ok, c_err = pcall(fn)
      if not c_ok then
        vim.notify("plugin " .. name .. ": cleanup error: " .. tostring(c_err), vim.log.levels.DEBUG)
      end
    end
    M._cleanup[name] = nil
  end

  -- Execute plugin configuration (measured separately so :PackProfile can
  -- distinguish vim.pack.add overhead from user-supplied config cost).
  local t_cfg_begin = vim.uv.hrtime()
  if spec.config then
    local cfg_ok, cfg_err = pcall(spec.config)
    if not cfg_ok then
      vim.notify("plugin " .. name .. ": config error: " .. tostring(cfg_err), vim.log.levels.ERROR)
    end
  end
  local t_end = vim.uv.hrtime()

  M._loaded[name] = true
  M._loading[name] = nil

  table.insert(M.timings, {
    name = name,
    at_ms = (t_begin - M._t0) / 1e6,
    dur_ms = (t_end - t_begin) / 1e6,
    config_ms = (t_end - t_cfg_begin) / 1e6,
    trigger = trigger or "eager",
  })
end

--- Load a plugin by name. Resolves dependencies, calls vim.pack.add(),
--- removes stale lazy triggers, and executes the config callback.
--- When spec.lazy is true, defers vim.pack.add + config to vim.schedule
--- unless loaded as a dependency (sync = true) to guarantee availability.
--- Safe to call multiple times — subsequent calls are no-ops.
---@param name string Plugin name (must match a registered spec)
---@param sync? boolean Force synchronous load (used for dependency resolution)
---@param trigger? string Reason for the load, captured in M.timings
function M.load(name, sync, trigger)
  if M._loaded[name] then
    return
  end

  -- Re-entrant load for an already-in-flight plugin means a dependency
  -- cycle (A -> B -> ... -> A). Report the full path so the author can
  -- break the cycle instead of silently returning and leaving a half-loaded
  -- parent that assumes its dep is ready.
  if M._loading[name] then
    local cycle = table.concat(M._load_stack, " -> ") .. " -> " .. name
    vim.notify("plugin: dependency cycle detected: " .. cycle, vim.log.levels.ERROR)
    return
  end

  local spec = M._specs[name]
  if not spec then
    return
  end

  M._loading[name] = true
  table.insert(M._load_stack, name)

  -- Resolve dependencies first (always synchronous to guarantee availability)
  if spec.deps then
    for _, dep in ipairs(spec.deps) do
      M.load(dep, true, "dep:" .. name)
    end
  end

  if spec.lazy and not sync then
    vim.schedule(function()
      do_load(name, spec, trigger)
    end)
  else
    do_load(name, spec, trigger)
  end

  -- Pop the stack regardless of lazy scheduling; _loading is cleared inside
  -- do_load when the actual load completes.
  for i = #M._load_stack, 1, -1 do
    if M._load_stack[i] == name then
      table.remove(M._load_stack, i)
      break
    end
  end
end

--- Check if a plugin has been loaded.
---@param name string Plugin name
---@return boolean
function M.is_loaded(name)
  return M._loaded[name] == true
end

-- Trigger installers --------------------------------------------------------

--- Register a cleanup function to run when a plugin loads.
--- Used to remove stale placeholder commands/keymaps/autocmds.
---@param name string Plugin name
---@param fn fun() Cleanup function
local function add_cleanup(name, fn)
  if not M._cleanup[name] then
    M._cleanup[name] = {}
  end
  table.insert(M._cleanup[name], fn)
end

--- Create a once-firing autocmd that loads the plugin on the specified events.
---@param spec PluginSpec Must have spec.event set
local function setup_event_trigger(spec)
  local id = vim.api.nvim_create_autocmd(spec.event, {
    group = augroup,
    once = true,
    callback = function(ev)
      M.load(spec.name, false, "event:" .. ev.event)
    end,
  })
  add_cleanup(spec.name, function()
    pcall(vim.api.nvim_del_autocmd, id)
  end)
end

--- Create a once-firing FileType autocmd. After loading, re-fires FileType
--- so the plugin can initialize for the buffer that triggered the load.
---@param spec PluginSpec Must have spec.ft set
local function setup_ft_trigger(spec)
  local id = vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = spec.ft,
    once = true,
    callback = function()
      M.load(spec.name, false, "ft:" .. vim.bo.filetype)
      -- Re-fire FileType so the plugin processes the current buffer
      vim.api.nvim_exec_autocmds("FileType", { pattern = vim.bo.filetype })
    end,
  })
  add_cleanup(spec.name, function()
    pcall(vim.api.nvim_del_autocmd, id)
  end)
end

--- Create placeholder user commands that load the plugin on first invocation,
--- then replay the original command (preserving bang, range, and arguments).
---@param spec PluginSpec Must have spec.cmd set
local function setup_cmd_trigger(spec)
  local placeholder_desc = "Lazy: " .. spec.name
  for _, cmd in ipairs(spec.cmd) do
    vim.api.nvim_create_user_command(cmd, function(ctx)
      -- Delete placeholder before loading so the real command can register
      vim.api.nvim_del_user_command(cmd)
      M.load(spec.name, false, "cmd:" .. cmd)
      -- Rebuild and replay the original command
      local replay = ""
      if ctx.range > 0 then
        replay = ctx.line1 .. "," .. ctx.line2
      end
      replay = replay .. cmd
      if ctx.bang then
        replay = replay .. "!"
      end
      if ctx.args ~= "" then
        replay = replay .. " " .. ctx.args
      end
      vim.cmd(replay)
    end, { nargs = "*", range = true, bang = true, desc = placeholder_desc })
    -- Only remove the placeholder, not a real command of the same name that
    -- the plugin may have just registered (e.g. sort.nvim registers :Sort
    -- from plugin/sort.lua, which vim.pack.add sources synchronously).
    add_cleanup(spec.name, function()
      local info = vim.api.nvim_get_commands({})[cmd]
      if info and info.definition == placeholder_desc then
        pcall(vim.api.nvim_del_user_command, cmd)
      end
    end)
  end
end

--- Create placeholder keymaps that load the plugin on first keypress,
--- then replay the original key sequence via feedkeys.
---@param spec PluginSpec Must have spec.keys set
local function setup_keys_trigger(spec)
  for _, key in ipairs(spec.keys) do
    local lhs = key[1]
    local modes = key.mode or "n"
    if type(modes) == "string" then
      modes = { modes }
    end
    vim.keymap.set(modes, lhs, function()
      -- Remove all placeholder keymaps for this binding
      for _, m in ipairs(modes) do
        pcall(vim.keymap.del, m, lhs)
      end
      M.load(spec.name, false, "keys:" .. lhs)
      -- Replay the original key sequence
      local encoded = vim.api.nvim_replace_termcodes(lhs, true, true, true)
      vim.api.nvim_feedkeys(encoded, "m", false)
    end, { desc = "Lazy: " .. (key.desc or spec.name) })
    add_cleanup(spec.name, function()
      for _, m in ipairs(modes) do
        pcall(vim.keymap.del, m, lhs)
      end
    end)
  end
end

-- Build dispatch ------------------------------------------------------------

--- Extract the pack name (repo directory name) from a source entry.
--- For "https://github.com/user/repo.nvim" returns "repo.nvim".
---@param src_entry string|table A single source entry (URL string or {src=...} table)
---@return string Pack name (last URL segment)
local function pack_name_from_src(src_entry)
  local url = type(src_entry) == "table" and src_entry.src or src_entry
  if type(url) ~= "string" then
    return ""
  end
  return url:match("[^/]+$") or ""
end

--- Global PackChanged handler dispatches to each spec's build function.
--- Matches the changed pack name against all src URLs in registered specs.
vim.api.nvim_create_autocmd("PackChanged", {
  group = augroup,
  callback = function(ev)
    local changed_name = ev.data.spec.name
    for _, spec in pairs(M._specs) do
      if spec.build then
        local src = spec.src
        if type(src) == "string" then
          src = { src }
        end
        for _, s in ipairs(src) do
          if pack_name_from_src(s) == changed_name then
            spec.build({ path = ev.data.path, name = changed_name, kind = ev.data.kind })
            break
          end
        end
      end
    end
  end,
})

--- Surface per-plugin installs in :messages. vim.pack's own output only
--- reports aggregate "Installing plugins (N/M)" progress; this adds one
--- history line per fresh clone so the user can see what was pulled.
--- Updates are skipped — :PackUpdate emits its own per-plugin notification
--- with the changelog.
vim.api.nvim_create_autocmd("PackChanged", {
  group = augroup,
  callback = function(ev)
    if ev.data.kind ~= "install" then
      return
    end
    local name = ev.data.spec and ev.data.spec.name or "?"
    vim.schedule(function()
      vim.notify(("vim.pack: installed %s"):format(name), vim.log.levels.INFO, { title = "vim.pack" })
    end)
  end,
})

-- Public API ----------------------------------------------------------------

--- Register a plugin spec. If no lazy triggers are defined (event/ft/cmd/keys),
--- the plugin is loaded immediately. Otherwise, placeholder triggers are set up
--- and the plugin loads on first use.
---@param spec PluginSpec Plugin specification
function M.add(spec)
  assert(spec.name, "plugin spec requires a 'name' field")
  assert(spec.src, "plugin spec requires a 'src' field")

  for k in pairs(spec) do
    if not vim.tbl_contains(known_fields, k) then
      vim.notify("plugin " .. spec.name .. ": unknown field '" .. k .. "'", vim.log.levels.WARN)
    end
  end

  M._specs[spec.name] = spec

  if spec.disabled then
    return
  end

  local has_trigger = spec.event or spec.ft or spec.cmd or spec.keys

  if not has_trigger then
    M.load(spec.name)
    return
  end

  -- Set up lazy-loading triggers (multiple can coexist, first to fire wins)
  if spec.event then
    setup_event_trigger(spec)
  end
  if spec.ft then
    setup_ft_trigger(spec)
  end
  if spec.cmd then
    setup_cmd_trigger(spec)
  end
  if spec.keys then
    setup_keys_trigger(spec)
  end
end

return M
