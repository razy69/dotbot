-- Automated session management
plugin.add({
  name = "persistence",
  src = "https://github.com/folke/persistence.nvim",
  -- `lazy` rather than `keys`: persistence has to be set up before VimLeavePre
  -- to save the session at all, so it must always load — just not during
  -- startup. A keys trigger would silently stop sessions being written.
  lazy = true,
  config = function()
    local persistence = require("persistence")
    persistence.setup({})

    utils.wk_add({
      { "<leader>qs", function() persistence.load() end,                desc = "Restore session",      mode = "n" },
      { "<leader>qS", function() persistence.select() end,              desc = "Select session",       mode = "n" },
      { "<leader>ql", function() persistence.load({ last = true }) end, desc = "Restore last session", mode = "n" },
      { "<leader>qd", function() persistence.stop() end,                desc = "Stop persistence",     mode = "n" },
    })
  end,
})
