-- Keymap manager with popup hints
plugin.add({
  name = "which_key",
  src = "https://github.com/folke/which-key.nvim",
  config = function()
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

    -- Disable existing bindings (blink.cmp overrides these for completion navigation)
    vim.keymap.set("i", "<C-n>", "<Nop>", { noremap = true })
    vim.keymap.set("i", "<C-p>", "<Nop>", { noremap = true })

    -- Route d/D through the black hole register so deletes don't clobber the
    -- unnamed register (and therefore don't change what `p` pastes). Mapping
    -- the operator itself covers every motion: dd, dw, daw, di", d2j, visual d…
    -- Use `"+y` / `yy` for explicit yank; if you ever need to delete AND yank,
    -- prefix with an explicit register, e.g. `"ad` or `"+d`.
    vim.keymap.set({ "n", "x" }, "d", "\"_d", { noremap = true, desc = "Delete (no yank)" })
    vim.keymap.set({ "n", "x" }, "D", "\"_D", { noremap = true, desc = "Delete to EOL (no yank)" })
    -- vim.keymap.set({ "n", "x" }, "x", "\"_x", { noremap = true, desc = "Delete char (no yank)" })
    -- vim.keymap.set({ "n", "x" }, "X", "\"_X", { noremap = true, desc = "Delete char before (no yank)" })

    -- Configure which-key
    local wk = require("which-key")
    wk.setup({
      -- Defer which-key for d/y operators so they don't intercept keystrokes
      -- before neonvim.glow can apply its visual highlights on yank/delete.
      defer = function(ctx)
        if vim.list_contains({ "d", "y" }, ctx.operator) then
          return true
        end
        return vim.list_contains({ "<C-V>", "V" }, ctx.mode)
      end,
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
    utils.wk_add({

      -- Which-Key
      { "<leader>`",    function() wk.show() end,    desc = "Show Keymap",                     mode = "n" },

      -- VIM
      { "<leader>w",    "<cmd>w<cr>",                desc = "Save buffer",                     mode = { "n" } },
      { "<leader>qq",   "<cmd>confirm q<cr>",        desc = "Quit buffer",                     mode = { "n" } },
      { "<leader>qa",   "<cmd>confirm qall<cr>",     desc = "Quit all buffers",                mode = { "n" } },
      { "<leader><bs>", "za",                        desc = "Fold/Unfold code",                mode = { "n" } },
      { "<leader>bg",   "<cmd>BackgroundToggle<cr>", desc = "Toggle background light/dark",    mode = { "n" } },
      { "<leader>qf",   "<cmd>copen<cr>",            desc = "Open quickfix",                   mode = { "n" } },
      { "+",            "<C-a>",                     desc = "Increment Numbers",               mode = { "n" } },
      { "-",            "<C-x>",                     desc = "Decrement Numbers",               mode = { "n" } },
      { "+",            "<C-a>gv",                   desc = "Increment Numbers",               mode = { "v" } },
      { "-",            "<C-x>gv",                   desc = "Decrement Numbers",               mode = { "v" } },
      { "<leader>/",    ":%s/",                      desc = "Substitute",                      mode = { "n" } },
      { "<leader>?",    ":%S/",                      desc = "Substitute (rev)",                mode = { "n" } },
      { "<leader>/",    ":s/",                       desc = "Substitute",                      mode = { "x" } },
      { "<leader>?",    ":S/",                       desc = "Substitute (rev)",                mode = { "x" } },
      { "<bs>",         "^",                         desc = "Go to first non-blank character", mode = { "n", "v" } },
      { "<bs><space>",  "$",                         desc = "Go to last character",            mode = { "n", "v" } },
      { "<leader>6",    "<cmd>bnext<cr>",            desc = "Next buffer",                     mode = { "n" } },
    })
  end,
})
