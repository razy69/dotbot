---@brief Aggregator for command modules. Each required file registers its
--- user commands and autocmds at require time. Add new command groups here.

require("commands.pack_update")
require("commands.pack_profile")
require("commands.lsp")
require("commands.mason")
