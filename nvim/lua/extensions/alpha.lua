--[[
  File: alpha.lua
  Description: Configuration of Alpha nvim
  Link: https://github.com/goolord/alpha-nvim
]]


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Hide/Show tabline
vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  desc = "disable tabline for alpha",
  callback = function()
    vim.opt.showtabline = 0
  end,
})

vim.api.nvim_create_autocmd("BufUnload", {
  buffer = 0,
  desc = "enable tabline after alpha",
  callback = function()
    vim.opt.showtabline = 2
  end,
})

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
  dashboard.button( "e", "  New file"          , ":ene <BAR> startinsert <CR>"),
  dashboard.button( "p", "  Open session"      , ":SessionManager load_session<CR>"),
  dashboard.button( "l", "󰕂  Open last session" , ":SessionManager load_last_session<CR>"),
  dashboard.button( "d", "  Delete session"    , ":SessionManager delete_session<CR>"),
  dashboard.button( "f", "󰆌  Search file"       , ":Telescope find_files<CR>"),
  dashboard.button( "g", "  Find in files"     , ":Telescope live_grep<CR>"),
  dashboard.button( "r", "  Recent files"      , ":Telescope oldfiles<CR>"),
  dashboard.button( "n", "󰎞  Open notes manager", ":Telekasten panel<CR>"),
  dashboard.button( "s", "  Settings"          , ":e $MYVIMRC <BAR> :cd %:p:h<CR>"),
  dashboard.button( "u", "󰁪  Update plugins"    , ":Lazy! sync <BAR> MasonUpdate<CR>"),
  dashboard.button( "q", "  Quit"              , ":qa<CR>"),
}

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
cmd([[
  autocmd FileType alpha setlocal nofoldenable
]])
