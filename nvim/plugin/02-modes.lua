-- Highlight cursor line color based on current mode
plugin.add({
  name = "modes",
  src = "https://github.com/mvllow/modes.nvim",
  event = plugin.LazyFile,
  config = function()
    require("modes").setup({
      set_cursorline = true,
      -- Default line_opacity is 0.15 which blends Visual bg down to a
      -- barely-perceptible tint against the mantle — selections look
      -- invisible. 0.35 keeps the subtle mode-hint on other events while
      -- making the visual-mode selection clearly readable.
      line_opacity = {
        copy = 0.15,
        delete = 0.15,
        change = 0.15,
        format = 0.15,
        insert = 0.15,
        replace = 0.15,
        select = 0.35,
        visual = 0.35,
      },
    })

    -- bug: "Press ENTER" prompt shows when entering vim
    vim.o.cmdheight = 0
  end,
})
