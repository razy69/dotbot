--[[
  File: noice_.lua
  Description: Plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  Link: https://github.com/folke/noice.nvim
]]

require("notify").setup({
  stages = "slide", -- fade_in_slide_out, fade, slide, static
  render = "default",
  timeout = 3000,
  minimum_width = 50,
  icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "" },
  level = vim.log.levels.INFO,
  fps = 120,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.60)
  end,
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100, focusable = false })
  end,
})

require("noice").setup({
  presets = {
    bottom_search = true,         -- use a classic bottom cmdline for search
    command_palette = true,       -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
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
    },
    hover = {
      enabled = true,
      silent = true,
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = false,
        trigger = false,
      },
    },
    message = {
      -- Messages shown by lsp servers
      enabled = true,
      view = "mini",
    }
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
    -- Kind:
    -- "" (empty)	Unknown (consider a feature-request: |bugs|)
    -- "confirm"	|confirm()| or |:confirm| dialog
    -- "confirm_sub"	|:substitute| confirm dialog |:s_c|
    -- "emsg"		Error (|errors|, internal error, |:throw|, …)
    -- "echo"		|:echo| message
    -- "echomsg"	|:echomsg| message
    -- "echoerr"	|:echoerr| message
    -- "lua_error"	Error in |:lua| code
    -- "rpc_error"	Error response from |rpcrequest()|
    -- "return_prompt"	|press-enter| prompt after a multiple messages
    -- "quickfix"	Quickfix navigation message
    -- "search_count"	Search count message ("S" flag of 'shortmess')
    -- "wmsg"		Warning ("search hit BOTTOM", |W10|, …)

    -- Redirect to mini
    {
      view = "notify",
      filter = {
        event = "msg_show",
        kind = "",
        any = {
          -- { find = "; after #%d+" },
          -- { find = "; before #%d+" },
          { find = "fewer lines" },
          { find = "No signature help" },
          { find = "written" },
        },
      },
    },
    -- Disable
    {
      filter = {
        event = "msg_show",
        kind = "search_count",
      },
      opts = { skip = true },
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
    backend = "nui", -- backend to use to show regular cmdline completions
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
  },

  views = {
    split = {
      win_options = { wrap = false },
      size = 16,
      close = { keys = { "q", "<CR>", "<Esc>" } },
    },
    mini = {
      win_options = {
        winblend = 0
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
    view_search = "virtualtext",
  },
})
