---@brief Startup bootstrap for user commands. `plugin/` is auto-sourced by
--- Neovim; `lua/commands/` is not. This one-liner pulls command modules in
--- early (prefix `00-`) so other plugin/ files can rely on them if needed.

require("commands")
