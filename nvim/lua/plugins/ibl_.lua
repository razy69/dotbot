--[[
  File: ibl_.lua
  Description: Adds indentation guides to Neovim.
  Link: https://github.com/lukas-reineke/indent-blankline.nvim
]]

local highlight = {
  "RainbowGrey",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "RainbowGrey", { fg = "#51576d" })
end)

require("ibl").setup({
  indent = { char = "│", highlight = highlight },
  scope = { enabled = false },
  exclude = {
    filetypes = {
      "help",
      "alpha",
      "neo-tree",
      "lazy",
      "mason",
      "notify",
    },
  },
})
