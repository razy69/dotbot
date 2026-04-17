-- Enhanced text objects (around/inside for function args, brackets, etc.)
plugin.add({
  name = "mini_ai",
  src = "https://github.com/echasnovski/mini.ai",
  event = plugin.LazyFile,
  config = function()
    local ai = require("mini.ai")
    ai.setup({
      n_lines = 500,
      custom_textobjects = {
        -- Whole buffer
        g = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line("$"),
            col = math.max(vim.fn.getline("$"):len(), 1),
          }
          return { from = from, to = to }
        end,
      },
    })
  end,
})
