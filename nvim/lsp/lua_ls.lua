-- lua-language-server: Lua LSP with Neovim runtime awareness.
-- Settings live here (not in .luarc.json) so lazydev.nvim can dynamically
-- extend workspace.library at runtime. lua_ls treats .luarc.json as the
-- authoritative source and ignores LSP-pushed library updates when it
-- exists — which silently disables lazydev's whole reason for being.
-- Plugin types are added on demand by lazydev.nvim — see plugin/02-lazydev.lua.
---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  -- Opt into neonvim.workspace_diagnostics' hidden-buffer scan so closed
  -- Lua files in the project get diagnosed without needing them open.
  -- lua_ls already analyses everything in workspace.library, so the
  -- marginal cost is small — diagnostics just need to be triggered.
  workspace_scan = true,
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        globals = { "vim", "lfs", "Snacks", "jit", "bit" },
        -- Suppress noisy warnings from incomplete type annotations in plugins
        disable = { "missing-parameter", "missing-fields", "different-requires" },
        -- Library files (VIMRUNTIME, lazydev-injected plugin sources) are
        -- only used for type resolution — never diagnose them. Without
        -- this, `vim` shows up as undefined in runtime/*.lua and any
        -- third-party library file scanned via the workspace.
        libraryFiles = "Disable",
      },
      hint = {
        enable = true,
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          "${3rd}/luv/library",
          "${3rd}/luassert/library",
          "${3rd}/lfs/library",
          "${3rd}/busted/library",
        },
        maxPreload = 5000,
        preloadFileSize = 10000,
      },
    },
  },
}
