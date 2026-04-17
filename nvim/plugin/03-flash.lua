-- Fast motion/navigation with search labels
plugin.add({
  name = "flash",
  src = "https://github.com/folke/flash.nvim",
  event = plugin.LazyFile,
  config = function()
    local flash = require("flash")

    flash.setup({
      modes = {
        char = {
          jump_labels = true
        }
      }
    })

    -- Add keymap
    utils.wk_add({
      { "S",  function() flash.jump() end,              desc = "Flash",             mode = { "n", "x", "o" } },
      { "St", function() flash.treesitter() end,        desc = "Flash Treesitter",  mode = { "n", "x", "o" } },
      { "R",  function() flash.treesitter_search() end, desc = "Treesitter Search", mode = { "o", "x" } },
    })
  end,
})
