---@brief Mason install commands. Splits "what to install" (declared by the
--- LSP + linter plugins) from "when to install" (explicit user command).
--- Startup emits a WARN for missing tools instead of auto-fetching from the
--- network, so a compromised/MITM'd Mason registry can't silently install
--- packages without consent.
---
--- LSP/linter plugins call M.register("lsp", specs) / M.register("lint", specs)
--- at their config time. Users then run `:LspInstall` / `:LintInstall` to pull
--- missing packages and upgrade any installed ones with newer registry
--- versions. `:MasonStatus` lists what's missing without installing.

local M = {}

---@class MasonInstallSpec
---@field package string Mason package name
---@field binary string Expected executable on PATH (skip install if present)

---@type table<string, MasonInstallSpec[]>
M._specs = { lsp = {}, lint = {} }

---@param kind "lsp"|"lint"
---@param specs MasonInstallSpec[]
function M.register(kind, specs)
  M._specs[kind] = specs
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

---@param kind "lsp"|"lint"
function M.warn_missing(kind)
  local gone = missing(M._specs[kind])
  if #gone == 0 then
    return
  end
  local names = {}
  for _, e in ipairs(gone) do
    table.insert(names, e.package)
  end
  local cmd = kind == "lsp" and ":LspInstall" or ":LintInstall"
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
    local pkg_ok, pkg = pcall(registry.get_package, entry.package)
    if pkg_ok and pkg:is_installed() then
      local current = pkg:get_installed_version()
      local latest_ok, latest = pcall(pkg.get_latest_version, pkg)
      if latest_ok and latest and current ~= latest and pkg:is_installable({ version = latest }) then
        table.insert(updates, { pkg = pkg, name = entry.package, latest = latest })
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

---@param kind "lsp"|"lint"
local function install(kind)
  local all_specs = M._specs[kind]
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    vim.notify("Mason: mason-registry not available yet — open a file first to trigger LSP/lint load", vim.log.levels.ERROR)
    return
  end
  registry.refresh(function()
    ---@type {pkg: table, name: string, action: "install"|"update", version: string?}[]
    local work = {}
    for _, entry in ipairs(missing(all_specs)) do
      local pkg_ok, pkg = pcall(registry.get_package, entry.package)
      if pkg_ok and not pkg:is_installed() then
        table.insert(work, { pkg = pkg, name = entry.package, action = "install" })
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

    local function render(msg)
      local finished = done == total
      local level = (finished and #failed > 0) and vim.log.levels.WARN or vim.log.levels.INFO
      local text
      if finished then
        if #failed == 0 then
          text = ("%s  done  %d/%d"):format(progress_bar(done, total), succeeded, total)
        else
          text = ("%s  done  %d ok, %d failed: %s"):format(
            progress_bar(done, total), succeeded, #failed, table.concat(failed, ", ")
          )
        end
      else
        text = ("%s  %d/%d  %s"):format(progress_bar(done, total), done, total, msg or "")
      end
      vim.notify(text, level, {
        id = notify_id,
        title = title,
        timeout = finished and 5000 or false,
      })
    end

    vim.schedule(function()
      render("starting")
    end)

    for _, item in ipairs(work) do
      local opts = item.action == "update" and { version = item.version } or nil
      item.pkg:install(opts):once("closed", vim.schedule_wrap(function()
        done = done + 1
        if item.pkg:is_installed() then
          succeeded = succeeded + 1
          local verb = item.action == "install" and "installed" or "updated"
          render(("%s %s"):format(verb, item.name))
        else
          table.insert(failed, item.name)
          render(("failed %s"):format(item.name))
        end
      end))
    end
  end)
end

vim.api.nvim_create_user_command("LspInstall", function()
  install("lsp")
end, { desc = "Install missing LSP servers via Mason (opt-in)" })

vim.api.nvim_create_user_command("LintInstall", function()
  install("lint")
end, { desc = "Install missing linters via Mason (opt-in)" })

vim.api.nvim_create_user_command("MasonStatus", function()
  for _, kind in ipairs({ "lsp", "lint" }) do
    local gone = missing(M._specs[kind])
    if #gone == 0 then
      vim.notify(("Mason %s: all tools present"):format(kind), vim.log.levels.INFO)
    else
      local names = {}
      for _, e in ipairs(gone) do
        table.insert(names, e.package)
      end
      vim.notify(("Mason %s missing: %s"):format(kind, table.concat(names, ", ")), vim.log.levels.WARN)
    end
  end
end, { desc = "Report missing Mason-installable LSP servers and linters" })

return M
