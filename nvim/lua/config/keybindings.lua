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

local noice = require("noice")
local wk = require("which-key")
local telescope_builtins = require("telescope.builtin")
local telescope = require("telescope")

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
  { "<leader>`",    function() wk.show() end,                                                    desc = "Show Keymap",                                  mode = "n" },

  -- Conform (Formatter)
  { "<leader>f",    "<cmd>Format<cr>",                                                           desc = "Format buffer",                                mode = "n" },

  -- VIM
  { "<C-t>",        "<cmd>tabnew<cr>",                                                           desc = "Open new tab",                                 mode = "n" },
  { "<C-n>",        "<cmd>tabN<cr>",                                                             desc = "Go to previous tab",                           mode = "n" },
  { "<C-p>",        "<cmd>tabp<cr>",                                                             desc = "Go to next tab",                               mode = "n" },
  { "<leader>w",    "<cmd>w<cr>",                                                                desc = "Save buffer",                                  mode = "n" },
  { "<leader>q",    "<cmd>confirm q<cr>",                                                        desc = "Quit buffer",                                  mode = "n" },
  { "<leader>Q",    "<cmd>confirm qall<cr>",                                                     desc = "Quit all buffers",                             mode = "n" },
  { "<leader><bs>", "za<cr>",                                                                    desc = "Fold/Unfold code",                             mode = "n" },
  { "<leader>bg",   "<cmd>BackgroundToggle<cr>",                                                 desc = "Toggle background light/dark",                 mode = "n" },
  { "<leader>qf",   "<cmd>copen<cr>",                                                            desc = "Open quickfix",                                mode = "n" },
  { "+",            "<C-a>",                                                                     desc = "Increment Numbers",                            mode = "n" },
  { "-",            "<C-x>",                                                                     desc = "Decrement Numbers",                            mode = "n" },
  { "+",            "<C-a>gv",                                                                   desc = "Increment Numbers",                            mode = "v" },
  { "-",            "<C-x>gv",                                                                   desc = "Decrement Numbers",                            mode = "v" },
  { "<leader>g",    ":Grep ",                                                                    desc = "[S]earch in [F]iles",                          mode = "n" },

  { "<leader>/",    ":%s/",                                                                      desc = "Substitute",                                   mode = "n" },
  { "<leader>?",    ":%S/",                                                                      desc = "Substitute (rev)",                             mode = "n" },
  { "<leader>/",    ":s/",                                                                       desc = "Substitute",                                   mode = "x" },
  { "<leader>?",    ":S/",                                                                       desc = "Substitute (rev)",                             mode = "x" },
  { "<bs>",         "^",                                                                         desc = "Go to first non-blank character",              mode = { "n", "v" } },

  -- Neotree
  { "<leader>e",    "<cmd>Neotree toggle<cr>",                                                   desc = "Open/Close Neotree",                           mode = "n" },

  -- Telescope
  { "gd",           function() telescope_builtins.lsp_definitions({ jump_type = "vsplit" }) end, desc = "LSP Go to definition",                         mode = "n" },
  { "gR",           function() telescope_builtins.lsp_references({ jump_type = "vsplit" }) end,  desc = "LSP Go to references",                         mode = "n" },
  { "<leader>O",    "<cmd>Telescope oldfiles<cr>",                                               desc = "Show recent files",                            mode = "n" },
  { "<leader>o",    "<cmd>Telescope find_files<cr>",                                             desc = "Search for a file",                            mode = "n" },
  { "<leader>i",    "<cmd>Telescope jumplist<cr>",                                               desc = "Go to previous location",                      mode = "n" },
  { "<leader>gr",   "<cmd>Telescope live_grep<cr>",                                              desc = "Find string in project",                       mode = "n" },
  { "<leader>b",    "<cmd>Telescope buffers<cr>",                                                desc = "Show all buffers",                             mode = "n" },
  { "<leader>z",    "<cmd>Telescope<cr>",                                                        desc = "Open Telescope",                               mode = "n" },
  { "<leader>d",    "<cmd>Telescope diagnostics<cr>",                                            desc = "Show diagnostics",                             mode = "n" },
  { "<leader>u",    "<cmd>Telescope undo<cr>",                                                   desc = "Undo menu",                                    mode = "n" },
  { "<leader>rr",   function() telescope.extensions.refactoring.refactors() end,                 desc = "Reactoring",                                   mode = { "n", "x" } },

  -- Trouble
  { "<leader>xx",   "<cmd>Trouble diagnostics toggle focus=true<cr>",                            desc = "Diagnostics (Trouble)",                        mode = "n" },
  { "<leader>xX",   "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",                          desc = "Buffer Diagnostics (Trouble)",                 mode = "n" },
  { "<leader>cs",   "<cmd>Trouble symbols toggle focus=false<cr>",                               desc = "Symbols (Trouble)",                            mode = "n" },
  { "<leader>cl",   "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",                desc = "LSP Definitions / references / ... (Trouble)", mode = "n" },
  { "<leader>xL",   "<cmd>Trouble loclist toggle<cr>",                                           desc = "Location List (Trouble)",                      mode = "n" },
  { "<leader>xQ",   "<cmd>Trouble qflist toggle<cr>",                                            desc = "Quickfix List (Trouble)",                      mode = "n" },

  -- Noice
  { "<leader>nl",   function() noice.cmd("last") end,                                            desc = "Last Noice message",                           mode = "n" },
  { "<leader>nh",   function() noice.cmd("history") end,                                         desc = "Noice message history",                        mode = "n" },

})
