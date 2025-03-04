require("globals")

-- Disable Exising Bindings
vim.api.nvim_set_keymap("i", "<C-n>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-p>", "<Nop>", { noremap = true })

-- KEYMAP
local wk = require("which-key")
wk.add({

  -- Which-Key
  { "<leader>`", function() require("which-key").show() end, desc = "Show Keymap", mode = "n" },

  -- LSP
  { "ga", function() vim.lsp.buf.code_action() end, desc = "LSP Code actions", mode = "n" },
  { "gr", function() vim.lsp.buf.rename() end, desc = "LSP rename object", mode = "n" },
  { "gD", function() vim.lsp.buf.declaration() end, desc = "LSP Go to declaration", mode = "n" },
  { "<leader>D", function() vim.diagnostic.open_float() end, desc = "LSP diagnostics", mode = "n" },
  { "<leader>R", "<cmd>LspRestart<cr>", desc = "Restart LSP Server", mode = "n" },

  -- VIM
  { "<leader>t", "<cmd>tabnew<cr>", desc = "Open new tab", mode = "n" },
  { "<leader>n", "<cmd>tabnext<cr>", desc = "Go to next tab", mode = "n" },
  { "<leader>p", "<cmd>tabprev<cr>", desc = "Go to previous tab", mode = "n" },
  { "<leader>q", "<cmd>quitall!<cr>", desc = "Force quit nvim", mode = "n" },
  { "<leader><bs>", "za<cr>", desc = "Fold/Unfold code", mode = "n" },
  { "<leader>bg", "<cmd>BackgroundToggle<cr>", desc = "Toggle background light/dark", mode = "n" },

  -- Neotree
  { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Open/Hide Neotree", mode = "n" },

  -- Neogen
  { "<leader>a", function() require("neogen").generate() end, desc = "Generate Annonations", mode = "n" },

  -- Telescope
  { "gd", function() require("telescope.builtin").lsp_definitions({ jump_type="vsplit" }) end, desc = "LSP Go to definition", mode = "n" },
  { "gR", function() require("telescope.builtin").lsp_references({ jump_type="vsplit" }) end, desc = "LSP Go to references", mode = "n" },
  { "<leader>O", "<cmd>Telescope oldfiles<cr>", desc = "Show recent files", mode = "n" },
  { "<leader>o", "<cmd>Telescope find_files<cr>", desc = "Search for a file", mode = "n" },
  { "<leader>i", "<cmd>Telescope jumplist<cr>", desc = "Go to previous location", mode = "n" },
  { "<leader>f", "<cmd>Telescope live_grep<cr>", desc = "Find string in project", mode = "n" },
  { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Show all buffers", mode = "n" },
  { "<leader>z", "<cmd>Telescope<cr>", desc = "Open Telescope", mode = "n" },
  { "<leader>d", "<cmd>Telescope diagnostics<cr>", desc = "Show diagnostics", mode = "n" },
  { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo menu", mode = "n" },
  { "<leader>h", "<cmd>Noice telescope<cr>", desc = "Open Noice history in Telescope", mode = "n" },

  -- Telekasten
  { "<leader>nn", "<cmd>Telekasten panel<cr>", desc = "Open Telekasten panel", mode = "n" },

})
