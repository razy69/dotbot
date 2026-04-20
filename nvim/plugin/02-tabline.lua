-- In-tree tabline (replaces bufferline). Uses native tab pages — the
-- bufferline spec was `mode = "tabs"`, so no buffer enumeration needed.
require("neonvim.tabline").setup()

utils.wk_add({
  { "<C-N>", "<cmd>tabnext<cr>",     desc = "Next tab",     mode = { "n" } },
  { "<C-P>", "<cmd>tabprevious<cr>", desc = "Previous tab", mode = { "n" } },
  { "<C-t>", "<cmd>tabnew<cr>",      desc = "New tab",      mode = { "n" } },
  { "<C-e>", "<cmd>new<cr>",         desc = "New buffer",   mode = { "n" } },
})
