--[[
  File: snacks_.lua
  Description: A collection of small QoL plugins for Neovim.
  Link: https://github.com/folke/snacks.nvim
]]

require("snacks").setup({
  animate = { enabled = true },
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').select()" },
        { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      { section = "startup" },
    },
  },
  image = { enabled = true },
  indent = {
    enabled = true,
    animate = {
      enabled = false,
    },
  },
  input = { enabled = false },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scratch = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
})
