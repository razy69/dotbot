--[[
  File: undo_glow_.lua
  Description: Adds a visual "glow" effect to your neovim operations.
  Link: https://github.com/y3owk1n/undo-glow.nvim
]]

local undo_glow = require("undo-glow")
local undo_glow_utils = require("undo-glow.utils")

undo_glow.setup({
  animation = {
    enabled = true,
    duration = 500,
    animtion_type = "zoom",
    window_scoped = true,
  },
  highlights = {
    undo = {
      hl_color = { bg = "#693232" }, -- Dark muted red
    },
    redo = {
      hl_color = { bg = "#2F4640" }, -- Dark muted green
    },
    yank = {
      hl_color = { bg = "#7A683A" }, -- Dark muted yellow
    },
    paste = {
      hl_color = { bg = "#325B5B" }, -- Dark muted cyan
    },
    search = {
      hl_color = { bg = "#5C475C" }, -- Dark muted purple
    },
    comment = {
      hl_color = { bg = "#7A5A3D" }, -- Dark muted orange
    },
    cursor = {
      hl_color = { bg = "#808080" }, -- muted white
    },
  },
  priority = 4096,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function()
    undo_glow.yank()
  end,
})

-- -- This only handles neovim instance and do not highlight when switching panes in tmux
vim.api.nvim_create_autocmd("CursorMoved", {
  desc = "Highlight when cursor moved significantly",
  callback = function()
    undo_glow.cursor_moved({
      animation = {
        animation_type = "slide",
      },
    })
  end,
})

-- This will handle highlights when focus gained, including switching panes in tmux
vim.api.nvim_create_autocmd("FocusGained", {
  desc = "Highlight when focus gained",
  callback = function()
    local opts_ = {
      animation = {
        animation_type = "slide",
      },
    }

    opts_ = undo_glow_utils.merge_command_opts("UgCursor", opts_)
    local pos = undo_glow_utils.get_current_cursor_row()

    undo_glow.highlight_region(vim.tbl_extend("force", opts_, {
      s_row = pos.s_row,
      s_col = pos.s_col,
      e_row = pos.e_row,
      e_col = pos.e_col,
      force_edge = opts_.force_edge == nil and true or opts_.force_edge,
    }))
  end,
})

vim.api.nvim_create_autocmd("CmdLineLeave", {
  pattern = { "/", "?" },
  desc = "Highlight when search cmdline leave",
  callback = function()
    undo_glow.search_cmd({
      animation = {
        animation_type = "fade",
      },
    })
  end,
})
