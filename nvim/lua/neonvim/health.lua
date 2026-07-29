---@brief Health check for the neonvim configuration.
--- Run with :checkhealth neonvim

local M = {}

--- Format a list as a comma-separated string, or "none" if empty/nil.
---@param list string[]|nil
---@return string
local function fmt_list(list)
  if not list or #list == 0 then
    return "none"
  end
  return table.concat(list, ", ")
end

--- Describe the trigger type(s) for a plugin spec.
---@param spec table PluginSpec
---@return string
local function describe_triggers(spec)
  local parts = {}
  if spec.event then table.insert(parts, "event: " .. fmt_list(spec.event)) end
  if spec.ft then table.insert(parts, "ft: " .. fmt_list(spec.ft)) end
  if spec.cmd then table.insert(parts, "cmd: " .. fmt_list(spec.cmd)) end
  if spec.keys then
    local lhs_list = {}
    for _, k in ipairs(spec.keys) do
      -- A malformed keys entry (no lhs) must not blow up the report.
      table.insert(lhs_list, tostring(k[1] or "?"))
    end
    table.insert(parts, "keys: " .. fmt_list(lhs_list))
  end
  if #parts == 0 then
    return "eager (no trigger)"
  end
  return table.concat(parts, " | ")
end

--- Count source URLs in a spec.
---@param spec table PluginSpec
---@return integer
local function count_sources(spec)
  local src = spec.src
  if type(src) == "string" then return 1 end
  if type(src) == "table" then return #src end
  return 0
end

--- Extract short repo names from src field.
---@param spec table PluginSpec
---@return string[]
local function source_names(spec)
  local src = spec.src
  if type(src) == "string" then src = { src } end
  -- A spec with no `src` (or a non-table one) would make ipairs() throw.
  if type(src) ~= "table" then return {} end
  local names = {}
  for _, s in ipairs(src) do
    local url = type(s) == "table" and s.src or s
    if type(url) == "string" then
      local name = url:match("[^/]+$") or url
      table.insert(names, name)
    end
  end
  return names
end

M.check = function()
  -- ── External Tools ──────────────────────────────────────────────────
  vim.health.start("External tools")

  local tools = {
    { cmd = "cargo", ok = "cargo found (blink.cmp native fuzzy)", warn = "cargo not found (blink.cmp will use Lua fuzzy fallback)" },
    { cmd = "rg",    ok = "ripgrep found",                        warn = "ripgrep not found (:grep will use default grepprg)" },
    { cmd = "fzf",   ok = "fzf found",                            warn = "fzf not found (fzf-lua may not work)" },
    { cmd = "git",   ok = "git found",                            warn = "git not found (plugin manager requires git)" },
    { cmd = "node",  ok = "node found",                           warn = "node not found (some LSP servers may need it)" },
  }
  for _, tool in ipairs(tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      vim.health.ok(tool.ok)
    else
      vim.health.warn(tool.warn)
    end
  end

  -- blink.cmp native library
  local ext = jit.os == "OSX" and "dylib" or (jit.os == "Windows" and "dll" or "so")
  local blink_lib = vim.fs.joinpath(
    vim.fn.stdpath("data"), "site", "pack", "core", "opt", "blink.cmp",
    "target", "release", "libblink_cmp_fuzzy." .. ext
  )
  if vim.uv.fs_stat(blink_lib) then
    vim.health.ok("blink.cmp native fuzzy library built")
  else
    vim.health.warn("blink.cmp native fuzzy library not built (using Lua fallback)")
  end

  -- ── LSP Servers ─────────────────────────────────────────────────────
  vim.health.start("LSP servers")

  local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
  -- readdir() raises E484 when the directory is missing, which would abort the
  -- rest of the health run. Stat first, and still pcall for the unreadable
  -- (permission) case: a health check must report, never throw.
  local lsp_files, lsp_dir_ok = {}, false
  if not vim.uv.fs_stat(lsp_dir) then
    vim.health.warn("No lsp/ directory at " .. lsp_dir)
  else
    local read_ok, files = pcall(vim.fn.readdir, lsp_dir)
    if read_ok then
      lsp_files, lsp_dir_ok = files or {}, true
    else
      vim.health.warn("Could not read " .. lsp_dir .. ": " .. tostring(files))
    end
  end

  local lsp_servers = {}
  for _, file in ipairs(lsp_files) do
    if file:match("%.lua$") then
      local server = file:gsub("%.lua$", "")
      table.insert(lsp_servers, server)
    end
  end

  if #lsp_servers == 0 then
    if lsp_dir_ok then
      vim.health.warn("No LSP server configs found in lsp/")
    end
  else
    vim.health.ok(#lsp_servers .. " LSP server configs found")
    for _, server in ipairs(lsp_servers) do
      local active = vim.lsp.get_clients({ name = server })
      if #active > 0 then
        local bufs = {}
        for _, client in ipairs(active) do
          for buf in pairs(client.attached_buffers) do
            table.insert(bufs, buf)
          end
        end
        vim.health.ok(server .. " — running (attached to " .. #bufs .. " buffer(s))")
      else
        vim.health.info(server .. " — not active")
      end
    end
  end

  -- ── Plugin Registry ─────────────────────────────────────────────────
  vim.health.start("Plugin registry")

  -- `plugin` is a global set by init.lua. Indexing it blind would throw if
  -- health ran before init (e.g. `-u NONE` plus a manual require).
  -- Report and fall through with empty tables rather than returning, so the
  -- Treesitter and Configuration sections below still render.
  local registry = type(plugin) == "table" and plugin or {}
  if not registry._specs then
    vim.health.error("plugin registry not available (init.lua not loaded?)")
  end
  local specs = registry._specs or {}
  local loaded = registry._loaded or {}
  local loading = registry._loading or {}

  -- Collect and sort plugin names
  local names = {}
  for name in pairs(specs) do
    table.insert(names, name)
  end
  table.sort(names)

  -- Counts
  local total = #names
  local n_disabled = 0
  local n_loaded = 0
  local n_pending = 0
  local n_eager = 0
  local n_lazy = 0
  local total_sources = 0

  for _, name in ipairs(names) do
    local spec = specs[name]
    total_sources = total_sources + count_sources(spec)
    if spec.disabled then
      n_disabled = n_disabled + 1
    elseif loaded[name] then
      n_loaded = n_loaded + 1
    else
      n_pending = n_pending + 1
    end
    local has_trigger = spec.event or spec.ft or spec.cmd or spec.keys
    if has_trigger then
      n_lazy = n_lazy + 1
    else
      n_eager = n_eager + 1
    end
  end

  vim.health.info(string.format(
    "Total: %d plugins (%d sources) — %d loaded, %d pending, %d disabled — %d eager, %d lazy",
    total, total_sources, n_loaded, n_pending, n_disabled, n_eager, n_lazy
  ))

  -- ── Per-Plugin Detail ───────────────────────────────────────────────
  vim.health.start("Plugin details")

  for _, name in ipairs(names) do
    local spec = specs[name]

    -- Status
    local status
    if spec.disabled then
      status = "disabled"
    elseif loaded[name] then
      status = "loaded"
    elseif loading[name] then
      status = "loading"
    else
      status = "pending"
    end

    -- Build detail lines
    local lines = {}
    table.insert(lines, "status: " .. status)
    table.insert(lines, "trigger: " .. describe_triggers(spec))
    table.insert(lines, "sources: " .. fmt_list(source_names(spec)))
    if spec.deps then
      table.insert(lines, "deps: " .. fmt_list(spec.deps))
    end
    if spec.lazy then
      table.insert(lines, "lazy: true (deferred vim.pack.add)")
    end
    if spec.build then
      table.insert(lines, "build: yes (post-install hook)")
    end

    local detail = table.concat(lines, "\n    ")
    local header = string.format("[%s] %s", status, name)

    if spec.disabled then
      vim.health.info(header .. "\n    " .. detail)
    elseif status == "loaded" then
      vim.health.ok(header .. "\n    " .. detail)
    elseif status == "pending" then
      vim.health.info(header .. "\n    " .. detail)
    else
      vim.health.warn(header .. "\n    " .. detail)
    end
  end

  -- ── Treesitter Parsers ──────────────────────────────────────────────
  vim.health.start("Treesitter parsers")

  local installed_parsers = vim.api.nvim_get_runtime_file("parser/*.so", true)
  local parser_names = {}
  for _, path in ipairs(installed_parsers) do
    local lang = vim.fn.fnamemodify(path, ":t:r")
    table.insert(parser_names, lang)
  end
  table.sort(parser_names)

  if #parser_names == 0 then
    vim.health.warn("No treesitter parsers installed")
  else
    vim.health.ok(#parser_names .. " treesitter parsers installed: " .. table.concat(parser_names, ", "))
  end

  -- ── Configuration ───────────────────────────────────────────────────
  vim.health.start("Configuration")

  vim.health.info("Leader: " .. vim.inspect(vim.g.mapleader))
  -- `colors_name` is unset until a colorscheme is actually applied; a raw
  -- concat there threw and aborted this whole section.
  vim.health.info("Colorscheme: " .. (vim.g.colors_name or "none"))
  vim.health.info("Background: " .. vim.o.background)
  vim.health.info("Clipboard: " .. vim.o.clipboard)
  vim.health.info("Shell: " .. vim.o.shell)
  vim.health.info("Undofile: " .. (vim.o.undofile and "enabled" or "disabled") .. " (" .. vim.o.undodir .. ")")

  local shadafile = vim.o.shadafile
  if shadafile and shadafile ~= "" then
    vim.health.ok("Per-project ShaDa: " .. shadafile)
  else
    vim.health.info("ShaDa: default")
  end
end

return M
