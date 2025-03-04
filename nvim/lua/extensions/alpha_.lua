--[[
	File: alpha.lua
	Description: Configuration of Alpha nvim
	Link: https://github.com/goolord/alpha-nvim
]]


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
  "                                                     ",
}

-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("f", "󰆌  Search file", ":Telescope find_files<CR>"),
  dashboard.button("g", "  Find in files", ":Telescope live_grep<CR>"),
  dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
  dashboard.button("n", "󰎞  Open notes manager", ":Telekasten panel<CR>"),
  dashboard.button("s", "  Settings", ":e $MYVIMRC <BAR> :cd %:p:h<CR>"),
  dashboard.button("u", "󰁪  Update plugins", ":Lazy! sync <BAR> MasonUpdate<CR>"),
  dashboard.button("q", "  Quit", ":qa<CR>"),
}

dashboard.opts.opts.noautocmd = false

-- Send config to alpha
alpha.setup(dashboard.opts)
