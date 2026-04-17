-- lua-language-server: Lua LSP with Neovim runtime awareness
---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = vim.fs.root(0, {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  }),
  single_file_support = true,
  log_level = vim.lsp.protocol.MessageType.Warning,
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        -- Suppress noisy warnings from incomplete type annotations in plugins
        disable = { "missing-parameters", "missing-fields" },
        -- Globals set in init.lua (_G.utils, _G.plugin) and lua/options.lua (_G.get_fold_text).
        -- `vim` is auto-recognised via the $VIMRUNTIME library below.
        globals = { "plugin", "utils", "get_fold_text" },
      },
      hint = {
        enable = true,
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        -- Prevents the "Do you need to configure your work environment?" popup
        checkThirdParty = false,
        -- Base Neovim runtime + test frameworks. Plugin types are added on
        -- demand by lazydev.nvim (see plugin/02-lazydev.lua) when you
        -- require() them — keeps startup fast vs. preloading all of rtp.
        library = {
          vim.fn.expand "$VIMRUNTIME",
          "${3rd}/busted/library",
          "${3rd}/luassert/library",
        },
        maxPreload = 5000,
        preloadFileSize = 10000,
      },
    },
  },
}
