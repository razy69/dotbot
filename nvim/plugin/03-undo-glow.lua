-- Visual feedback for undo/redo/yank/paste/search operations
plugin.add({
  name = "undo_glow",
  src = "https://github.com/y3owk1n/undo-glow.nvim",
  event = plugin.LazyFile,
  config = function()
    local undo_glow = require("undo-glow")
    local undo_glow_utils = require("undo-glow.utils")
    undo_glow.setup({
      animation = {
        enabled = true,
        duration = 500,
        animation_type = "zoom",
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
      callback = function() pcall(undo_glow.yank) end,
    })

    -- Highlight when cursor jumps significantly (within neovim, not across tmux panes)
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Highlight when cursor moved significantly",
      callback = function()
        pcall(undo_glow.cursor_moved, { animation = { animation_type = "slide" } })
      end,
    })

    -- Highlight cursor position when regaining focus (including tmux pane switches)
    vim.api.nvim_create_autocmd("FocusGained", {
      desc = "Highlight when focus gained",
      callback = function()
        pcall(function()
          local opts_ = { animation = { animation_type = "slide" } }
          opts_ = undo_glow_utils.merge_command_opts("UgCursor", opts_)
          local pos = undo_glow_utils.get_current_cursor_row()
          undo_glow.highlight_region(vim.tbl_extend("force", opts_, {
            s_row = pos.s_row,
            s_col = pos.s_col,
            e_row = pos.e_row,
            e_col = pos.e_col,
            force_edge = opts_.force_edge == nil and true or opts_.force_edge,
          }))
        end)
      end,
    })

    vim.api.nvim_create_autocmd("CmdLineLeave", {
      pattern = { "/", "?" },
      desc = "Highlight when search cmdline leave",
      callback = function()
        pcall(undo_glow.search_cmd, { animation = { animation_type = "fade" } })
      end,
    })

    -- Add keymap
    utils.wk_add({
      { "u", function() undo_glow.undo() end,                                                     desc = "Undo with highlight",        mode = { "n" } },
      { "U", function() undo_glow.redo() end,                                                     desc = "Redo with highlight",        mode = { "n" } },
      { "p", function() undo_glow.paste_below() end,                                              desc = "Paste below with highlight", mode = { "n" } },
      { "P", function() undo_glow.paste_above() end,                                              desc = "Paste above with highlight", mode = { "n" } },
      { "n", function() undo_glow.search_next({ animation = { animation_type = "strobe" } }) end, desc = "Search next with highlight", mode = { "n" } },
      { "N", function() undo_glow.search_prev({ animation = { animation_type = "strobe" } }) end, desc = "Search prev with highlight", mode = { "n" } },
      { "*", function() undo_glow.search_star({ animation = { animation_type = "strobe" } }) end, desc = "Search star with highlight", mode = { "n" } },
      { "#", function() undo_glow.search_hash({ animation = { animation_type = "strobe" } }) end, desc = "Search hash with highlight", mode = { "n" } },
    })
  end,
})
