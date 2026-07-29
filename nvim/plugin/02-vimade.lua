-- Dim inactive windows/buffers
plugin.add({
  name = "vimade",
  src = "https://github.com/tadaa/vimade",
  -- Not UIEnter: that fires *during* startup (after VimEnter), so it was never
  -- a deferral. `lazy` pushes it to the first main-loop tick instead.
  lazy = true,
  config = function()
    -- Configure vimade
    require("vimade").setup({
      recipe = { "default", { animate = true } },
      fadelevel = 0.4,
    })
  end,
})
