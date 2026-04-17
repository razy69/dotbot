-- Highlight cursor line color based on current mode
plugin.add({
  name = "modes",
  src = "https://github.com/mvllow/modes.nvim",
  event = plugin.LazyFile,
  config = function()
    require("modes").setup({
      set_cursorline = true,
    })

    -- bug: "Press ENTER" prompt shows when entering vim
    -- vim.o.cmdheight = 0
  end,
})
