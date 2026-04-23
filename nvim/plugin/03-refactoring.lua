-- Treesitter-based refactoring operations (extract, inline, etc.)
plugin.add({
  name = "refactoring",
  src = "https://github.com/ThePrimeagen/refactoring.nvim",
  deps = { "async", "treesitter" },
  keys = {
    { "<leader>re", desc = "Extract function" },
    { "<leader>rf", desc = "Extract function to file" },
    { "<leader>rv", desc = "Extract variable" },
    { "<leader>ri", desc = "Inline variable" },
    { "<leader>rI", desc = "Inline function" },
    { "<leader>rb", desc = "Extract block" },
    { "<leader>rB", desc = "Extract block to file" },
  },
  config = function()
    local refactoring = require("refactoring")
    refactoring.setup({})

    utils.wk_add({
      { "<leader>re", function() refactoring.refactor("Extract Function") end,         desc = "Extract function",         mode = "x" },
      { "<leader>rf", function() refactoring.refactor("Extract Function To File") end, desc = "Extract function to file", mode = "x" },
      { "<leader>rv", function() refactoring.refactor("Extract Variable") end,         desc = "Extract variable",         mode = "x" },
      { "<leader>ri", function() refactoring.refactor("Inline Variable") end,          desc = "Inline variable",          mode = { "n", "x" } },
      { "<leader>rI", function() refactoring.refactor("Inline Function") end,          desc = "Inline function",          mode = "n" },
      { "<leader>rb", function() refactoring.refactor("Extract Block") end,            desc = "Extract block",            mode = "n" },
      { "<leader>rB", function() refactoring.refactor("Extract Block To File") end,    desc = "Extract block to file",    mode = "n" },
    })
  end,
})
