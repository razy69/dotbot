--[[
  File: fzf_lua_.lua
  Description: Fuzzy finder
  See: https://github.com/ibhagwan/fzf-lua
]]

require("fzf-lua").setup({
  "fzf-native", winopts = { preview = { default = "bat" } },
})
