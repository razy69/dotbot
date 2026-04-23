-- Highlight cursor line color based on current mode
plugin.add({
  name = "modes",
  src = "https://github.com/mvllow/modes.nvim",
  config = function()
    -- Pass colors explicitly from catppuccin's palette. Two reasons:
    --   1. modes.nvim internally does `colors.change = config.colors.change
    --      or colors.delete` (lua/modes.lua), so without an explicit `change`
    --      the change cursorline ends up red instead of green — our
    --      `ModesChange = { bg = colors.green }` in custom_highlights is
    --      silently overwritten by modes.nvim's own `hi ModesChange …` call.
    --   2. Reading directly from the palette keeps the two plugins in sync
    --      when :BackgroundToggle swaps flavours (the ColorScheme autocmd
    --      modes.nvim registers re-runs define() and re-reads synIDattr,
    --      but that only works for groups modes.nvim actually queries — it
    --      doesn't query `ModesChange`).
    -- Catppuccin has one green and one yellow per flavour, so "dark green"
    -- and "light yellow" map to the closest palette equivalents: teal is the
    -- darker, blue-shifted green, and yellow is already a muted/light shade.
    local palette = utils.get_palette()
    require("modes").setup({
      set_cursorline = true,
      colors = {
        copy = palette.yellow,   -- light yellow
        delete = palette.red,
        change = palette.teal,   -- dark green
        format = palette.peach,
        insert = palette.blue,
        replace = palette.blue,
        visual = palette.mauve,
      },
      -- Mode-specific line/selection opacities. visual/select use 0.5 so
      -- the selection renders distinctly mauve against catppuccin's
      -- surface colours instead of blending into them; the transient
      -- cursorline tints (copy/delete/change/…) stay subtle at 0.15 so
      -- they flash without obscuring code.
      line_opacity = {
        copy = 0.15,
        delete = 0.15,
        change = 0.15,
        format = 0.15,
        insert = 0.15,
        replace = 0.15,
        select = 0.5,
        visual = 0.5,
      },
    })

    -- bug: "Press ENTER" prompt shows when entering vim
    vim.o.cmdheight = 0
  end,
})
