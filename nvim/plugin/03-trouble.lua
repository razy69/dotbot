-- Pretty diagnostics, references, quickfix and location lists
plugin.add({
  name = "trouble",
  src = "https://github.com/folke/trouble.nvim",
  cmd = { "Trouble" },
  keys = {
    { "<leader>xx", desc = "Diagnostics (Trouble)" },
    { "<leader>xX", desc = "Buffer diagnostics (Trouble)" },
    { "<leader>xs", desc = "Symbols (Trouble)" },
    { "<leader>xr", desc = "References (Trouble)" },
    { "<leader>xq", desc = "Quickfix (Trouble)" },
    { "<leader>xl", desc = "Loclist (Trouble)" },
  },
  config = function()
    local trouble = require("trouble")
    trouble.setup({
      modes = {
        symbols = {
          win = {
            type = "split",
            relative = "win",
            position = "right",
            size = 0.3,
            pinned = true,
            focus = false,
          },
        },
      },
    })

    utils.wk_add({
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)",        mode = "n" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)", mode = "n" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)",            mode = "n" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>",           desc = "References (Trouble)",         mode = "n" },
      { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>",                 desc = "Quickfix (Trouble)",           mode = "n" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Loclist (Trouble)",            mode = "n" },
    })
  end,
})
