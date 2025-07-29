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
        { icon = " ", key = "o", desc = "Neorg", action = ":Neorg" },
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = function()
            vim.cmd("cd " .. vim.fn.stdpath("config"))
            Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
          end
        },
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
  input = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  rename = { enabled = true },
  scratch = { enabled = false },
  scroll = { enabled = true },
  statuscolumn = {
    enabled = true,
    left = { "mark", "sign" },
    right = { "fold", "git" },
    folds = {
      open = false,
      git_hl = false,
    },
    refresh = 50,
  },
})

-- https://www.reddit.com/r/neovim/comments/1hkpgar/a_per_project_shadafile/
vim.opt.shadafile = (function() -- Per project shadafile
  local data = tostring(vim.fn.stdpath("data"))
  local git_root = require("snacks.git").get_root()
  local cwd = git_root or vim.fn.getcwd()
  local cwd_b64 = vim.base64.encode(cwd)
  local file = vim.fs.joinpath(data, "project_shada", cwd_b64)
  vim.fn.mkdir(vim.fs.dirname(file), "p")
  return file
end)()
