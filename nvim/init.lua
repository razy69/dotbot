-- When invoked as `nvim <dir>`, switch the global cwd to that directory so
-- pickers (fzf-lua, snacks), linters, formatters, and shell-out commands
-- all root at the user's intended path — not the shell's cwd at launch.
-- Snacks explorer separately notices the dir buffer and opens itself
-- there; this just keeps the global cwd in sync with that intent.
do
  local args = vim.fn.argv()
  if #args == 1 then
    local stat = vim.uv.fs_stat(args[1])
    if stat and stat.type == "directory" then
      vim.api.nvim_set_current_dir(vim.fs.normalize(vim.fn.fnamemodify(args[1], ":p")))
    end
  end
end

-- Resync $PWD with the kernel's view of the current directory. When the user
-- cd's through a symlink (e.g. ~/dev/foo → /Volumes/.../foo), the shell keeps
-- PWD as the symlinked path while the kernel uses the real one. Subprocesses
-- that prefer $PWD over getcwd() (notably Go — os.Getwd, which delve uses)
-- then disagree with us about module boundaries and fail with "directory
-- outside main module".
vim.env.PWD = vim.fn.getcwd()

-- Expose a module as a global, asserting no plugin/runtime has already
-- claimed the name. Catches accidental shadowing before it turns into a
-- silent misbehavior (e.g. a plugin defining its own `utils` global).
local function set_global(name, value)
  local existing = rawget(_G, name)
  assert(
    existing == nil,
    ("init.lua: refusing to overwrite existing global '%s' (type=%s)"):format(name, type(existing))
  )
  rawset(_G, name, value)
end

-- Utilities (exposed as global for convenience in files)
set_global("utils", require("utils"))

-- Plugin manager (exposed as global for convenience in plugin/ files)
set_global("plugin", require("plugin"))

-- Options
require("options")

-- Autocmd
require("autocmd")

-- Editor extensions (in-tree replacements for small plugins)
require("neonvim.numb_peek").setup()
require("neonvim.toggle_word").setup()
