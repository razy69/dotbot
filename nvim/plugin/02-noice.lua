-- Enhanced UI for messages, cmdline, and popupmenu
plugin.add({
  name = "noice",
  src = {
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/folke/noice.nvim",
  },
  event = { "UIEnter" },
  config = function()
    -- Configure noice
    local noice = require("noice")
    noice.setup({
      -- We intentionally wrap vim.notify below (to mirror notifications into
      -- :messages). Disable noice's periodic integrity check so it doesn't
      -- warn "vim.notify has been overwritten by another plugin".
      health = { checker = false },

      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
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

      -- Route noisy/transient messages (yank counts, fold errors, etc.) to the mini view
      -- instead of showing them as full notifications.
      routes = {
        -- Skip our own notify-history mirror (see vim.notify wrap below).
        -- The msg_show event adds the message to :messages history, but noice
        -- must not render it as a popup since vim.notify already did that.
        {
          filter = { event = "msg_show", kind = "notify_history" },
          opts = { skip = true },
        },
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

    -- Add keymap
    utils.wk_add({
      { "<leader>nl", function() noice.cmd("last") end, desc = "Last Noice message",    mode = "n" },
      { "<leader>nh", function() noice.cmd("fzf") end,  desc = "Noice message history", mode = "n" },
    })

    -- Mirror every vim.notify call into Vim's native :messages history.
    -- Noice replaces vim.notify with its popup UI but does NOT write to
    -- :messages, so the native `:messages` command would otherwise lose
    -- notification history. We wrap noice's notify and forward each line via
    -- `nvim_echo(..., history = true, { kind = "notify_history" })`, which
    -- adds the line to :messages. The matching noice route above skips the
    -- popup re-display so we don't get duplicate notifications.
    -- `vim.schedule` defers the wrap until after all UIEnter handlers finish,
    -- so we wrap noice's final hook and are not overridden afterwards.
    vim.schedule(function()
      local wrapped_notify = vim.notify
      vim.notify = function(msg, level, opts)
        wrapped_notify(msg, level, opts)
        if type(msg) ~= "string" or msg == "" then
          return
        end
        local prefix = opts and opts.title and ("[" .. opts.title .. "] ") or ""
        for _, line in ipairs(vim.split(msg, "\n", { plain = true })) do
          if line ~= "" then
            pcall(vim.api.nvim_echo, { { prefix .. line } }, true, { kind = "notify_history" })
          end
        end
      end
    end)
  end,
})
