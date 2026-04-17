-- Dim inactive windows/buffers
plugin.add({
  name = "vimade",
  src = "https://github.com/tadaa/vimade",
  event = { "UIEnter" },
  config = function()
    -- Configure vimade
    require("vimade").setup({
      recipe = { "default", { animate = true } },
      fadelevel = 0.4,
    })
  end,
})
