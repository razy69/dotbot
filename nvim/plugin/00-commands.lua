---@brief Startup bootstrap for user commands. `plugin/` is auto-sourced by
--- Neovim; `lua/commands/` is not.
---
--- Deferred to the first main-loop tick: the command modules are ~1000 lines
--- whose only startup-time job is calling nvim_create_user_command, so none of
--- it needs to run before the first screen is drawn. Anything that needs a
--- command module *during* startup requires it directly (e.g. plugin/03-lsp.lua
--- requires "commands.mason" for its install registry), which is unaffected.
vim.schedule(function()
  require("commands")
end)
