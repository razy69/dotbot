--[[
  File: fzf_lua_.lua
  Description: Fuzzy finder
  See: https://github.com/ibhagwan/fzf-lua
]]

local fzf_lua = require("fzf-lua")

fzf_lua.setup({
  "fzf-native",
  winopts = {
    preview = { default = "bat" },
    split = "belowright new" -- open in split right of current window
  },
  fzf_opts = { ["--cycle"] = true },
  grep = {
    resume         = true, -- resume last search
    rg_opts        = "--sort-files --hidden --column --line-number --no-heading " ..
        "--color=always --smart-case -g '!{.git,node_modules}/*'",  -- sort results (to be always in the same order, may impact perf)
    rg_glob        = true,      -- enable glob parsing by default to all
    glob_flag      = "--iglob", -- for case sensitive globs use '--glob'
    glob_separator = "%s%-%-"   -- query separator pattern (lua): ' --'
  },
})

fzf_lua.register_ui_select(function(_, items)
  local min_h, max_h = 0.15, 0.70
  local h = (#items + 4) / vim.o.lines
  if h < min_h then
    h = min_h
  elseif h > max_h then
    h = max_h
  end
  return { winopts = { height = h, width = 0.60, row = 0.40 } }
end)
