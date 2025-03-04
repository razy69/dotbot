--[[
  File: noice.lua
  Description: Noice plugin configuration (with lspconfig)
  See: https://github.com/folke/noice.nvim
]]

local noice = require("noice")

noice.setup({

  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    hover = {
      enabled = false,
    },
    signature = {
      enabled = false,
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
		enabled = true, -- enables the Noice popupmenu UI
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
		border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
		win_options = {
			winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
		},
	},

})
