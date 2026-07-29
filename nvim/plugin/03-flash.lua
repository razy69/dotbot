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
    --
    -- flash.nvim's documented layout. Deliberately no key that is a prefix of
    -- another: the previous S / St pair made every plain S (the common case)
    -- wait out 'timeoutlen' before firing. Shadowing builtin s (= cl) and
    -- S (= cc) is the accepted tradeoff; use cl / cc for those.
    utils.wk_add({
      { "s", function() flash.jump() end,              desc = "Flash",             mode = { "n", "x", "o" } },
      -- No "x": visual-mode S belongs to nvim-surround (surround a selection),
      -- which sources after this file and silently won the mapping anyway.
      -- Declaring it here explicitly instead of relying on load order.
      { "S", function() flash.treesitter() end,        desc = "Flash Treesitter",  mode = { "n", "o" } },
      { "R", function() flash.treesitter_search() end, desc = "Treesitter Search", mode = { "o", "x" } },
    })
  end,
})
