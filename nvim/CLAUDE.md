# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Neovim 0.12 configuration ("neonvim") using the native `vim.pack` system — not lazy.nvim. Part of a dotbot-managed dotfiles setup.

## Architecture

### Entry Point & Module Loading

`init.lua` loads `options` and `autocmd`. Plugin files in `plugin/` are auto-sourced by Neovim's runtime at startup (standard Neovim behavior).

### Plugin System

- **Package manager**: Native `vim.pack.add()` with `nvim-pack-lock.json` for pinning revisions
- **Feature gating**: The `disabled` field in each plugin spec prevents loading (checked inside `plugin.add()`). The registry lives in `lua/plugin.lua` with `is_enabled()` for runtime queries.
- **Load order**: Filename prefixes control precedence: `00-` (user commands bootstrap) → `01-` (theme, which-key, shared libs) → `02-` (core: LSP, completion, fuzzy finder, UI) → `03-` (editing utilities)
- **Lazy loading**: Prefer a trigger on the spec over eager loading. In order of preference: `keys` / `cmd` / `ft` (load on first real use) → `event = plugin.LazyFile` (first file read, for anything buffer-oriented) → `lazy = true` (always loads, but deferred to the first main-loop tick — use only when the plugin must be present to do its job, e.g. `persistence` needs to exist before `VimLeavePre`). No trigger at all means eager: reserve it for `which_key` (every other config calls `utils.wk_add` synchronously) and anything that must run before ShaDa is read.
- **Trigger completeness**: A `keys`/`cmd` list must name *every* mapping and command the spec's `config()` registers. A missing entry is a silently dead keymap until one of the listed triggers fires.
- **Deferred config caveat**: A plugin loading on `plugin.LazyFile` has already missed `FileType` for the buffer that triggered it. If its `config()` registers a `FileType` handler, it must also apply that handler to already-loaded buffers (see `plugin/02-treesitter.lua`).

### LSP Configuration

Each language server is a standalone file in `lsp/` returning a `vim.lsp.Config` table. Mason auto-discovers and installs servers by scanning filenames in that directory — adding a new server only requires creating a new `lsp/<server>.lua` file. Set `mason = "<package>"` in the config when the Mason package name differs from `cmd[1]`.

Use `root_markers = { ... }`, never `root_dir = vim.fs.root(0, ...)`. Calling `vim.fs.root` at file scope resolves the root **once**, at load time, and Neovim caches the resolved config for the session — so every later buffer attaches with the first project's root. `root_markers` is resolved per buffer. A server needing only `.git` should declare nothing: `plugin/03-lsp.lua` sets `root_markers = { ".git" }` on the `*` config.

Anything that depends on the environment at attach time (a venv path, a toolchain) belongs in `before_init`/`on_init` for the same reason — file scope runs once per session, not once per client.

`single_file_support` and `log_level` are nvim-lspconfig fields that native `vim.lsp.Config` silently ignores. Don't add them.

### Keymaps

All keymaps are defined via `utils.wk_add()` calls inside individual plugin config files. There is no centralized keymap file.

Always use `utils.wk_add()`, never `require("which-key").add()` directly: which-key's top-level `add()` only appends to a queue that is drained once, inside `setup()`, on `VimEnter`. Any call after that drain — which includes every `event`/`keys`/`cmd`-triggered plugin config and every `LspAttach` handler — is silently discarded. `utils.wk_add` routes through `which-key.config` to register synchronously. This is also why the `which_key` spec must stay eager.

### Theming

Catppuccin is deeply integrated. `utils.lua` provides `get_flavor()` and `get_palette()` helpers. Dark/light mode toggles via the `THEME_MODE` environment variable and `:BackgroundToggle` command.

## Conventions

- **Indentation**: 2 spaces default, 4 for Python (via `ftplugin/python.lua`)
- **Leader key**: Space (both leader and localleader)
- **Plugin config files**: One file per plugin in `plugin/`, registered via `plugin.add()` with optional `disabled` flag
- **LSP configs**: One file per server in `lsp/`, returning `vim.lsp.Config`
- **Custom filetypes**: Defined in `filetype.lua`
