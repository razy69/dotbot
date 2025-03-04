--[[
	File: alpha_.lua
	Description: Configuration of Alpha nvim
	Link: https://github.com/goolord/alpha-nvim
]]


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local logo = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

-- Set logo
dashboard.section.header.val = vim.split(logo, "\n")

-- Set menu
dashboard.section.buttons.val = {
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("f", "󰆌  Search file", ":FzfLua files<CR>"),
  dashboard.button("g", "  Find in files", ":FzfLua live_grep<CR>"),
  dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
  dashboard.button("p", "  Restore Session", [[<cmd> lua require("persistence").select() <cr>]]),
  dashboard.button("s", "  Settings", ":e $MYVIMRC <BAR> :cd %:p:h<CR>"),
  dashboard.button("u", "󰁪  Update plugins", ":Lazy! sync <BAR> MasonUpdate<CR>"),
  dashboard.button("q", "  Quit", ":qa<CR>"),
}

for _, button in ipairs(dashboard.section.buttons.val) do
  button.opts.hl = "AlphaButtons"
  button.opts.hl_shortcut = "AlphaShortcut"
end

dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.footer.opts.hl = "AlphaFooter"
dashboard.opts.layout[1].val = 8
dashboard.opts.opts.noautocmd = false

-- Send config to alpha
alpha.setup(dashboard.opts)

vim.api.nvim_create_autocmd("User", {
  once = true,
  pattern = "LazyVimStarted",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    dashboard.section.footer.val = "⚡ Neovim loaded "
        .. stats.loaded
        .. "/"
        .. stats.count
        .. " plugins in "
        .. ms
        .. "ms"
    pcall(vim.cmd.AlphaRedraw)
  end,
})
