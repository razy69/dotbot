--[[
  File: ibl_.lua
  Description: Adds indentation guides to Neovim.
  Link: https://github.com/lukas-reineke/indent-blankline.nvim
]]

local highlight = {
  "IBLIndentGuide1",
}

vim.api.nvim_set_hl(0, "IBLIndentGuide1", { fg = "#51576d" })

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
