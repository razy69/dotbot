--[[
  File: fzf_lua_.lua
  Description: Fuzzy finder.
  Link: https://github.com/ibhagwan/fzf-lua
]]

local fzf_lua = require("fzf-lua")

fzf_lua.setup({
  "fzf-native",
  file_icon_padding = " ",
  winopts = {
    preview    = {
      default = "bat",
      wrap    = true,
      winopts = {
        signcolumn = "yes",
      },
    },
    -- split = "belowright new" -- open in split right of current window
    height     = 0.85, -- window height
    width      = 0.80, -- window width
    row        = 0.35, -- window row position (0=top, 1=bottom)
    col        = 0.50, -- window col position (0=left, 1=right)
    backdrop   = 70,   -- 0 is fully opaque, 100 is fully transparent
    treesitter = {
      enabled    = true,
      fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
    },
  },
  fzf_opts = {
    ["--cycle"] = true,
  },
  oldfiles = {
    include_current_session = true,
    stat_file = true, -- verify files exist on disk
  },
  previewers = {
    builtin = {
      syntax_limit_b = 1024 * 1000, -- 1MB
    },
  },
  grep = {
    resume         = true,                                         -- resume last search
    rg_opts        = "--sort-files --hidden --column --line-number --no-heading " ..
        "--color=always --smart-case -g '!{.git,node_modules}/*'", -- sort results (to be always in the same order, may impact perf)
    rg_glob        = true,                                         -- enable glob parsing by default to all
    glob_flag      = "--iglob",                                    -- for case sensitive globs use '--glob'
    glob_separator = "%s%-%-"                                      -- query separator pattern (lua): ' --'
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
