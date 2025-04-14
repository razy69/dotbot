--[[
	File: alpha_.lua
	Description: Fast and fully programmable greeter for neovim.
	Link: https://github.com/goolord/alpha-nvim
]]


local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local autocmd = require("config.autocmd")
local utils = require("config.utils")
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

-- Alpha Enter
local alpha_group = autocmd.augroup("alpha")
vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
  desc = "Alpha Enter",
  group = alpha_group,
  callback = function()
    if (vim.bo.filetype ~= "alpha") then
      return
    end

    vim.cmd("highlight clear EoLSpace")

    -- Cursor hide
    local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 100
    vim.api.nvim_set_hl(0, "Cursor", hl)
    vim.opt.guicursor:append("a:Cursor/lCursor")

    local lualine = utils.prequire("lualine")
    if lualine then
      lualine.hide()
    end

    local illuminate = utils.prequire("illuminate")
    if illuminate then
      illuminate.invisible_buf()
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave" }, {
  desc = "Alpha Enter",
  group = alpha_group,
  callback = function()
    if (vim.bo.filetype ~= "alpha") then
      return
    end

    -- Cursor show
    local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 0
    vim.api.nvim_set_hl(0, "Cursor", hl)
    vim.opt.guicursor:remove("a:Cursor/lCursor")

    vim.opt.foldenable = false
    local lualine = utils.prequire("lualine")
    if lualine then
      lualine.hide({ unhide = true })
    end

    local illuminate = utils.prequire("illuminate")
    if illuminate then
      illuminate.visible_buf()
    end
  end,
})

vim.api.nvim_create_autocmd("TabNewEntered", {
  desc = "Open Alpha on new tab",
  group = alpha_group,
  callback = function()
    alpha.start()
  end,
})
