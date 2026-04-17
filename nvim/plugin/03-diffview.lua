-- Git diff viewer and file history
plugin.add({
  name = "diffview",
  src = "https://github.com/dlyongemallo/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewToggle",
    "DiffviewFileHistory",
    "DiffviewDiffFiles",
    "DiffviewLog",
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_mixed" },
        file_history = { layout = "diff2_horizontal" },
      },
    })

    utils.wk_add({
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Diff view",            mode = "n" },
      { "<leader>gf", "<cmd>DiffviewFileHistory<cr>",   desc = "File history",         mode = "n" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history", mode = "n" },
    })
  end,
})
