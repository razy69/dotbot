require("globals")

-- Disable Exising Bindings
vim.api.nvim_set_keymap("i", "<C-n>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-p>", "<Nop>", { noremap = true })

-- KEYMAP
local wk = require("which-key")

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

wk.add({

  -- Which-Key
  { "<leader>`",    function() wk.show() end,                                                              desc = "Show Keymap",                  mode = "n" },

  -- LSP
  {
    "K",
    function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end,
    desc = "LSP Code Hover or Fold view",
    mode = "n"
  },
  { "I",            function() vim.lsp.buf.implementation() end,                                           desc = "LSP Code Implementation",      mode = "n" },
  { "ga",           function() vim.lsp.buf.code_action() end,                                              desc = "LSP Code actions",             mode = "n" },
  { "gr",           function() vim.lsp.buf.rename() end,                                                   desc = "LSP rename object",            mode = "n" },
  { "gD",           function() vim.lsp.buf.declaration() end,                                              desc = "LSP Go to declaration",        mode = "n" },
  { "<leader>D",    function() vim.diagnostic.open_float() end,                                            desc = "LSP diagnostics",              mode = "n" },
  { "<leader>R",    "<cmd>LspRestart<cr>",                                                                 desc = "Restart LSP Server",           mode = "n" },

  -- Conform (Formatter)
  { "<leader>f",    "<cmd>Format<cr>",                                                                     desc = "Format buffer",                mode = "n" },

  -- VIM
  { "<C-t>",        "<cmd>tabnew<cr>",                                                                     desc = "Open new tab",                 mode = "n" },
  { "<C-n>",        "<cmd>tabN<cr>",                                                                       desc = "Go to previous tab",           mode = "n" },
  { "<C-p>",        "<cmd>tabp<cr>",                                                                       desc = "Go to next tab",               mode = "n" },
  { "<leader>w",    "<cmd>w<cr>",                                                                          desc = "Save buffer",                  mode = "n" },
  { "<leader>q",    "<cmd>q<cr>",                                                                          desc = "Quit buffer",                  mode = "n" },
  { "<leader>Q",    "<cmd>qall!<cr>",                                                                      desc = "Quit all buffers",             mode = "n" },
  { "<leader><bs>", "za<cr>",                                                                              desc = "Fold/Unfold code",             mode = "n" },
  { "<leader>bg",   "<cmd>BackgroundToggle<cr>",                                                           desc = "Toggle background light/dark", mode = "n" },

  -- Neotree
  { "<leader>e",    "<cmd>Neotree toggle<cr>",                                                             desc = "Open/Hide Neotree",            mode = "n" },

  -- Neogen
  { "<leader>a",    function() require("neogen").generate() end,                                           desc = "Generate Annonations",         mode = "n" },

  -- Telescope
  { "gd",           function() require("telescope.builtin").lsp_definitions({ jump_type = "vsplit" }) end, desc = "LSP Go to definition",         mode = "n" },
  { "gR",           function() require("telescope.builtin").lsp_references({ jump_type = "vsplit" }) end,  desc = "LSP Go to references",         mode = "n" },
  { "<leader>O",    "<cmd>Telescope oldfiles<cr>",                                                         desc = "Show recent files",            mode = "n" },
  { "<leader>o",    "<cmd>Telescope find_files<cr>",                                                       desc = "Search for a file",            mode = "n" },
  { "<leader>i",    "<cmd>Telescope jumplist<cr>",                                                         desc = "Go to previous location",      mode = "n" },
  { "<leader>g",    "<cmd>Telescope live_grep<cr>",                                                        desc = "Find string in project",       mode = "n" },
  { "<leader>b",    "<cmd>Telescope buffers<cr>",                                                          desc = "Show all buffers",             mode = "n" },
  { "<leader>z",    "<cmd>Telescope<cr>",                                                                  desc = "Open Telescope",               mode = "n" },
  { "<leader>d",    "<cmd>Telescope diagnostics<cr>",                                                      desc = "Show diagnostics",             mode = "n" },
  { "<leader>u",    "<cmd>Telescope undo<cr>",                                                             desc = "Undo menu",                    mode = "n" },
  { "<leader>rr",   function() require("telescope").extensions.refactoring.refactors() end,                mode = { "n", "x" } },

  -- Telekasten
  { "<leader>n",    "<cmd>Telekasten panel<cr>",                                                           desc = "Open Telekasten panel",        mode = "n" },

  -- Flash
  { "s",            function() require("flash").jump() end,                                                desc = "Flash",                        mode = { "n", "x", "o" } },
  { "S",            function() require("flash").treesitter() end,                                          desc = "Flash Treesitter",             mode = { "n", "x", "o" } },
  { "r",            function() require("flash").remote() end,                                              desc = "Remote Flash",                 mode = "o" },
  { "R",            function() require("flash").treesitter_search() end,                                   desc = "Treesitter Search",            mode = { "o", "x" } },
  { "<c-s>",        function() require("flash").toggle() end,                                              desc = "Toggle Flash Search",          mode = { "c" } },

})
