---@brief Shared utility functions for the neonvim configuration.

---@class neonvim.utils
local M = {}

--- Create a namespaced augroup with auto-clear.
--- All augroups are prefixed with "razyvim_" to avoid collisions.
---@param name string Augroup suffix (e.g. "Lsp" -> "razyvim_Lsp")
---@return integer augroup_id
function M.augroup(name)
  return vim.api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

--- Stop and close a libuv timer handle, tolerating nil and
--- already-closed handles. Stopping alone leaks the handle — libuv only
--- releases it on close — so every timer teardown must do both.
---@param timer uv.uv_timer_t? Timer handle (nil is a no-op)
function M.close_timer(timer)
  if not timer then return end
  pcall(function() timer:stop() end)
  pcall(function() timer:close() end)
end

--- Add which-key mappings that work both pre- and post-VimEnter.
--- which-key v3's top-level `require("which-key").add()` only appends to
--- a queue (which-key/init.lua:48-50); the queue is drained exactly once
--- inside `setup()` on VimEnter (which-key/config.lua:283-287). Any calls
--- made after the drain — e.g. from an LspAttach handler of a lazy-loaded
--- LSP plugin, or from any `event`-triggered plugin whose config fires
--- after VimEnter — silently accumulate and are never processed.
--- Routing through the config module registers synchronously, which is
--- the same thing setup() does when it drains the queue.
--- Must be called AFTER which-key's setup() (guaranteed by plugin/ load
--- order: 01-which-key.lua sources before any 02-/03- caller).
---@param spec table which-key mapping spec (same shape as wk.add argument)
function M.wk_add(spec)
  require("which-key.config").add(spec)
end

--- Verify a directory is safe to scan-and-execute from (used to gate
--- `dofile()` and `vim.lsp.enable()` on user-scanned config directories).
--- Rejects the path if any of the following is true:
---   - it doesn't exist or isn't a directory
---   - the path itself (fs_lstat, does NOT follow symlinks) is a symlink —
---     prevents a link inside the dir's parent from redirecting the scan
---   - the resolved target is owned by a different user
---   - the resolved target is group- or world-writable
--- Symlink rejection is at the *directory* level. Entries inside (e.g. a
--- linter spec file that is itself a symlink) are still `dofile`-able; if
--- that becomes a concern, caller must lstat each entry separately.
---@param path string Absolute path to the directory
---@return boolean trusted true if safe to dofile files inside
function M.is_trusted_dir(path)
  local lstat = vim.uv.fs_lstat(path)
  if not lstat then
    return false
  end
  if lstat.type == "link" then
    return false
  end
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "directory" then
    return false
  end
  local my_uid = vim.uv.getuid and vim.uv.getuid() or nil
  if my_uid and stat.uid ~= my_uid then
    return false
  end
  -- Reject group- or world-writable (mode bits 0020 and 0002). The earlier
  -- version only rejected world-writable, which missed the case where the
  -- directory is group-writable and the user shares a group with an
  -- untrusted account.
  if bit.band(stat.mode, 0x12) ~= 0 then
    return false
  end
  return true
end

--- Get the catppuccin flavor based on the current background setting.
--- "dark" -> "frappe", "light" -> "latte"
---@return "frappe"|"latte"
function M.get_flavor()
  return (vim.o.background == "dark") and "frappe" or "latte"
end

---@class neonvim.CatppuccinPalette
---@field rosewater string
---@field flamingo string
---@field pink string
---@field mauve string
---@field red string
---@field maroon string
---@field peach string
---@field yellow string
---@field green string
---@field teal string
---@field sky string
---@field sapphire string
---@field blue string
---@field lavender string
---@field text string
---@field subtext1 string
---@field subtext0 string
---@field overlay2 string
---@field overlay1 string
---@field overlay0 string
---@field surface2 string
---@field surface1 string
---@field surface0 string
---@field base string
---@field mantle string
---@field crust string

--- Get the catppuccin color palette for the current background setting.
---@return neonvim.CatppuccinPalette
function M.get_palette()
  local palettes = require("catppuccin.palettes")
  return palettes.get_palette(M.get_flavor())
end

return M
