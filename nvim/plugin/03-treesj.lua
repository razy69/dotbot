-- Toggle between single-line and multi-line code blocks
plugin.add({
  name = "treesj",
  src = "https://github.com/Wansmer/treesj",
  keys = {
    { "<leader>j", desc = "Toggle single-line/multi-line code block" },
  },
  config = function()
    require("treesj").setup({
      max_join_length = 500,
      use_default_keymaps = false,
    })

    -- Add keymap
    utils.wk_add({
      { "<leader>j", "<cmd>TSJToggle<cr>", desc = "Toggle join/split", mode = { "n" } }
    })
  end,
})
