--[[
  File: noice_.lua
  Description: Plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  Link: https://github.com/folke/noice.nvim
]]

require("notify").setup({
  stages = "static", -- fade_in_slide_out, fade, slide, static
  render = "default",
  timeout = 3000,
  minimum_width = 50,
  icons = { ERROR = "", WARN = "", INFO = "", DEBUG = "", TRACE = "" },
  level = vim.log.levels.INFO,
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
    inc_rename = true,            -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true,        -- add a border to hover docs and signature help
  },

  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
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
    popupmenu = {
      win_options = {
        winblend = 0
      }
    },
    popup = {
      win_options = { wrap = false },
    },
  },

  routes = {
    --   Kind:
    --   "" (empty)	Unknown (consider a feature-request: |bugs|)
    --   "confirm"	|confirm()| or |:confirm| dialog
    --   "confirm_sub"	|:substitute| confirm dialog |:s_c|
    --   "emsg"		Error (|errors|, internal error, |:throw|, …)
    --   "echo"		|:echo| message
    --   "echomsg"	|:echomsg| message
    --   "echoerr"	|:echoerr| message
    --   "lua_error"	Error in |:lua| code
    --   "rpc_error"	Error response from |rpcrequest()|
    --   "return_prompt"	|press-enter| prompt after a multiple messages
    --   "quickfix"	Quickfix navigation message
    --   "search_count"	Search count message ("S" flag of 'shortmess')
    --   "wmsg"		Warning ("search hit BOTTOM", |W10|, …)
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "E85: There is no listed buffer" },
          { find = "E486: Pattern not found: ?$" },
          { find = "E490: No fold found" },
          { find = "Already at oldest change" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
          { find = "^%d+ fewer lines;?" },
          { find = "^%d+ more lines;?" },
          { find = "^%d+ line lesses;?" },
          { find = ".*Pattern not found.*$" },
          { find = "^%d+ lines .ed %d+ times?$" },
          { find = "^%d+ lines yanked$" },
          { find = "%d+L, %d+B" },
          { kind = "wmsg" },
        },
      },
      view = "mini",
    },
  },
})
