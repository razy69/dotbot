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
- **Load order**: Filename prefixes control precedence: `00-` (shared libs) → `01-` (theme, which-key) → `02-` (core: LSP, completion, fuzzy finder, UI) → `03-` (editing utilities)
- **Lazy loading pattern**: Heavy plugins (treesitter, flash, conform) use a `BufReadPost`/`BufNewFile` autocmd with `once = true` to defer loading until first file access

### LSP Configuration

Each language server is a standalone file in `lsp/` returning a `vim.lsp.Config` table. Mason auto-discovers and installs servers by scanning filenames in that directory — adding a new server only requires creating a new `lsp/<server>.lua` file.

### Keymaps

All keymaps are defined via `which-key.add()` calls inside individual plugin config files. There is no centralized keymap file.

### Theming

Catppuccin is deeply integrated. `utils.lua` provides `get_flavor()` and `get_palette()` helpers. Dark/light mode toggles via the `THEME_MODE` environment variable and `:BackgroundToggle` command.

## Conventions

- **Indentation**: 2 spaces default, 4 for Python (via `ftplugin/python.lua`)
- **Leader key**: Space (both leader and localleader)
- **Plugin config files**: One file per plugin in `plugin/`, registered via `plugin.add()` with optional `disabled` flag
- **LSP configs**: One file per server in `lsp/`, returning `vim.lsp.Config`
- **Custom filetypes**: Defined in `filetype.lua`
