-- Guided code exploration tool for the current symbol
plugin.add({
  name = "wayfinder",
  src = "https://github.com/error311/wayfinder.nvim",
  cmd = { "Wayfinder", "WayfinderOpen" },
  keys = {
    { "<leader>wf", desc = "Wayfinder" },
  },
  config = function()
    require("wayfinder").setup({})

    utils.wk_add({
      { "<leader>wf", "<cmd>Wayfinder<cr>", desc = "Wayfinder" },
    })
  end
})
