--[[
  File: treesitter_.lua
  Description: Parser generator tool and an incremental parsing library.
  Link: https://github.com/tree-sitter/tree-sitter
]]

require("nvim-treesitter.configs").setup({
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  endwise = { enable = true },
  autotag = { enable = true },
  matchup = { enable = true },
  indent = {
    enable = true,
  },
})
