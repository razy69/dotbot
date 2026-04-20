-- Git signs in the sign column and inline blame
plugin.add({
  name = "gitsigns",
  src = "https://github.com/lewis6991/gitsigns.nvim",
  event = plugin.LazyFile,
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = '▍' },
        change       = { text = '▍' },
        delete       = { text = '▍' },
        topdelete    = { text = '▍' },
        changedelete = { text = '▍' },
        untracked    = { text = '▍' },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 50,
      },
      current_line_blame_formatter = "\t <author> (<author_time:%R>) - <summary>",
      -- Disable threaded diffs: the worker's string.dump'd closure loses
      -- upvalues when re-loaded inside uv.new_work, and any error surfaces
      -- as stray "Luv thread:\n[NULL]" lines in :messages. Running the diff
      -- on the main loop is fine here — hunks are small and async-scheduled.
      _threaded_diff = false,
    })
  end,
})
