--[[
  File: noice_.lua
  Description: Plugin that completely replaces the UI for messages, cmdline and the popupmenu
  See: https://github.com/folke/noice.nvim
]]

require("notify").setup({
  stages = "static", -- fade_in_slide_out, fade, slide, static
  render = "default",
  timeout = 1200,
  minimum_width = 50,
  icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "" },
  level = vim.log.levels.INFO,
  fps = 5,
  background_colour = "#000000",
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100 })
  end,
})

require("noice").setup({
  presets = {
    bottom_search = true,         -- use a classic bottom cmdline for search
    command_palette = true,       -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true,            -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true,        -- add a border to hover docs and signature help
  },

  lsp = {
    progress = {
      enabled = true,
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    hover = {
      enabled = true,
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = false,
        trigger = false,
      },
    },
  },

  cmdline = {
    enabled = true, -- enables the Noice cmdline UI
    view = "cmdline",
    conceal = false,
    format = {
      cmdline = { pattern = "^:", icon = "❯", lang = "vim" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
    },
  },

  routes = {
    {
      filter = { event = "notify", find = "No information available", }, -- Suppress 'No information available' popup message
      opts = { skip = true },
    },
    { -- route long messages to split
      filter = {
        event = "msg_show",
        any = { { min_height = 5 }, { min_width = 200 } },
        ["not"] = {
          kind = { "confirm", "confirm_sub", "return_prompt", "quickfix", "search_count" },
        },
        blocking = false,
      },
      view = "messages",
      opts = { stop = true },
    },
    { -- route long messages to split
      filter = {
        event = "msg_show",
        any = { { min_height = 5 }, { min_width = 200 } },
        ["not"] = {
          kind = { "confirm", "confirm_sub", "return_prompt", "quickfix", "search_count" },
        },
        blocking = true,
      },
      view = "mini",
    },
    { -- hide `written` message
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },
    { -- send annoying msgs to mini
      filter = {
        event = "msg_show",
        any = {
          { find = "; after #%d+" },
          { find = "; before #%d+" },
          { find = "fewer lines" },
        },
      },
      view = "mini",
    },
  },

  cmdline_popup = {
    position = {
      row = 5,
      col = "50%",
    },
    size = {
      width = 60,
      height = "auto",
    },
  },

  popupmenu = {
    enabled = true,  -- enables the Noice popupmenu UI
    backend = "cmp", -- backend to use to show regular cmdline completions
    relative = "editor",
    position = {
      row = 8,
      col = "50%",
    },
    size = {
      width = 60,
      height = 10,
    },
    border = "rounded",
    win_options = {
      winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
    },
  },

  views = {
    split = {
      win_options = { wrap = false },
      size = 16,
      close = { keys = { "q", "<CR>", "<Esc>" } },
    },
    mini = {
      win_options = {
        winblend = 100
      }
    },
    cmdline_popup = {
      win_options = {
        winblend = 0
      }
    },
    popupmenu = {
      win_options = {
        winblend = 0
      }
    },
    popup = {
      win_options = { wrap = false },
    },
  },

  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_history = "messages",
    view_search = false,
  },

  health = { checker = false },
})
