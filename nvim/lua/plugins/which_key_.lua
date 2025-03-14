--[[
  File: which_key_.lua
  Description: Helps you remember your Neovim keymaps, by showing available keybindings in a popup as you type.
  Link: https://github.com/folke/which-key.nvim
]]

-- Modes
--
--  n	Normal
--  v	Visual and Select
--  s	Select
--  x	Visual
--  o	Operator-pending
--  !	Insert and Command-line
--  i	Insert
--  l	":lmap" mappings for Insert, Command-line and Lang-Arg
--  c	Command-line
--  t	Terminal-Job

local utils = require("config.utils")
local wk = require("which-key")

-- Disable Exising Bindings
vim.api.nvim_set_keymap("i", "<C-n>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-p>", "<Nop>", { noremap = true })

wk.setup({
  win = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    wo = {
      winblend = 0,
    }
  },
  plugins = {
    marks = true,       -- shows a list of your marks on ' and `
    registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
  }
})

-- KEYMAP
wk.add({

  -- Which-Key
  { "<leader>`",    function() wk.show() end,    desc = "Show Keymap",                     mode = "n" },

  -- VIM
  { "<C-t>",        "<cmd>tabnew<cr>",           desc = "Open new tab",                    mode = "n" },
  { "<C-tn>",       "<cmd>tabN<cr>",             desc = "Go to previous tab",              mode = "n" },
  { "<C-tp>",       "<cmd>tabp<cr>",             desc = "Go to next tab",                  mode = "n" },
  { "<leader>w",    "<cmd>w<cr>",                desc = "Save buffer",                     mode = "n" },
  { "<leader>qq",   "<cmd>confirm q<cr>",        desc = "Quit buffer",                     mode = "n" },
  { "<leader>qa",   "<cmd>confirm qall<cr>",     desc = "Quit all buffers",                mode = "n" },
  { "<leader><bs>", "za<cr>",                    desc = "Fold/Unfold code",                mode = "n" },
  { "<leader>bg",   "<cmd>BackgroundToggle<cr>", desc = "Toggle background light/dark",    mode = "n" },
  { "<leader>qf",   "<cmd>copen<cr>",            desc = "Open quickfix",                   mode = "n" },
  { "+",            "<C-a>",                     desc = "Increment Numbers",               mode = "n" },
  { "-",            "<C-x>",                     desc = "Decrement Numbers",               mode = "n" },
  { "+",            "<C-a>gv",                   desc = "Increment Numbers",               mode = "v" },
  { "-",            "<C-x>gv",                   desc = "Decrement Numbers",               mode = "v" },
  { "<leader>/",    ":%s/",                      desc = "Substitute",                      mode = "n" },
  { "<leader>?",    ":%S/",                      desc = "Substitute (rev)",                mode = "n" },
  { "<leader>/",    ":s/",                       desc = "Substitute",                      mode = "x" },
  { "<leader>?",    ":S/",                       desc = "Substitute (rev)",                mode = "x" },
  { "<bs>",         "^",                         desc = "Go to first non-blank character", mode = { "n", "v" } },
  { "<bs><space>",  "$",                         desc = "Go to last character",            mode = { "n", "v" } },
})

local persistence = utils.prequire("persistence")
if persistence then
  wk.add({
    { "<leader>qs", function() persistence.select() end,              desc = "Select session to load",             mode = "n" },
    { "<leader>qS", function() persistence.load() end,                desc = "Load session for current directory", mode = "n" },
    { "<leader>ql", function() persistence.load({ last = true }) end, desc = "Load last session",                  mode = "n" },
  })
end

local fzf_lua = utils.prequire("fzf-lua")
if fzf_lua then
  wk.add({
    { "<leader>O",    function() fzf_lua.oldfiles() end,                         desc = "Show recent files",       mode = "n" },
    { "<leader>o",    function() fzf_lua.files() end,                            desc = "Search for a file",       mode = "n" },
    { "<leader>i",    function() fzf_lua.jumps() end,                            desc = "Go to previous location", mode = "n" },
    { "<leader>gr",   function() fzf_lua.live_grep({ multiprocess = true }) end, desc = "Find string in project",  mode = "n" },
    { "<leader>b",    function() fzf_lua.buffers() end,                          desc = "Show all buffers",        mode = "n" },
    { "<leader>todo", "<cmd>TodoFzf<cr>",                                        desc = "Todo things",             mode = "n" },
  })
end

local trouble = utils.prequire("trouble")
if trouble then
  wk.add({
    { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>",   desc = "Diagnostics (Trouble)",        mode = "n" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)", mode = "n" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)",            mode = "n" },
  })
end

local noice = utils.prequire("noice")
if noice then
  wk.add({
    { "<leader>nl", function() noice.cmd("last") end, desc = "Last Noice message",    mode = "n" },
    { "<leader>nh", function() noice.cmd("fzf") end,  desc = "Noice message history", mode = "n" },
  })
end

local flash = utils.prequire("flash")
if flash then
  wk.add({
    { "S",  function() flash.jump() end,              desc = "Flash",             mode = { "n", "x", "o" } },
    { "St", function() flash.treesitter() end,        desc = "Flash Treesitter",  mode = { "n", "x", "o" } },
    { "R",  function() flash.treesitter_search() end, desc = "Treesitter Search", mode = { "o", "x" } },
  })
end

local neotree = utils.prequire("neo-tree.command")
if neotree then
  wk.add({
    { "<leader>e", function() neotree.execute({ toggle = true }) end, desc = "Toggle NeoTree", mode = { "n" } },
  })
end
