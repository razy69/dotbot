--[[
  File: _config.lua
  Description: Plugins list.
  See: https://github.com/folke/lazy.nvim
]]

return {
  -- Completions
  {
    "saghen/blink.cmp",
    build = "cargo build --release",
    event = { "InsertEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("plugins.blink_cmp_")
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("plugins.lsp_")
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    build = ":TSUpdateSync",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("plugins.treesitter_")
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    keys = {
      { "<leader>f", "<cmd>Format<cr>", desc = "Format buffer", mode = "n" },
    },
    config = function()
      require("plugins.conform_")
    end
  },

  -- UI
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("plugins.noice_")
    end,
  },

  -- Quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({
        func_map = {
          vsplit = "s",
        },
      })
    end
  },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("plugins.lualine_")
    end,
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    config = function()
      require("plugins.fzf_lua_")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Open/Close Neotree", mode = "n" },
    },
    config = function()
      require("plugins.neotree_")
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      modes = {
        symbols = {
          win = {
            type = "split",
            relative = "win",
            position = "right",
            size = 0.3,
            pinned = true,
            focus = false,
          },
        },
      },
    },
  },

  -- VSCode like winbar
  {
    "utilyre/barbecue.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    config = function()
      require("plugins.barbecue_")
    end,
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  },

  -- Highlight arguments
  {
    "m-demare/hlargs.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = { "nvim-treesitter" },
  },

  -- Highlighting Words
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      require("plugins.illuminate_")
    end,
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.gitsigns_")
    end,
  },

  -- Git diffview
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  },

  -- Git tool
  {
    "TimUntersberger/neogit",
    cmd = "Neogit",
    config = function()
      require("neogit").setup({
        kind = "split", -- opens neogit in a split
        signs = {
          -- { CLOSED, OPENED }
          section = { "", "", },
          item = { "", "", },
          hunk = { "", "" },
        },
        integrations = { diffview = true }, -- adds integration with diffview.nvim
      })
    end,
  },

  -- Indent Guide
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      require("plugins.hlchunk_")
    end
  },

  -- Split/join code blocks
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>j", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    config = function()
      require("treesj").setup({
        max_join_length = 500,
        use_default_keymaps = false,
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {
      enable_check_bracket_line = true,
      check_ts = true,
    },
  },

  -- Peek lines
  {
    "nacro90/numb.nvim",
    opts = {},
  },

  -- Scroll animation
  {
    "karb94/neoscroll.nvim",
    opts = {},
  },

  -- Scroll bar
  {
    "lewis6991/satellite.nvim",
    opts = {
      handlers = {
        cursor = {
          enable = false,
        },
        gitsigns = {
          enable = false,
        },
      },
    },
  },

  -- Animated cursor
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.8,               -- 0.6      [0, 1]
      trailing_stiffness = 0.5,      -- 0.3      [0, 1]
      distance_stop_animating = 0.5, -- 0.1      > 0
      hide_target_hack = false,      -- true     boolean
    },
  },

  -- Markdown
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("plugins.markdown_")
    end,
  },

  -- Help view
  {
    "OXY2DEV/helpview.nvim",
    ft = "help",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      highlight = {
        -- vimgrep regex, supporting the pattern TODO(name):
        pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
      },
      search = {
        -- ripgrep regex, supporting the pattern TODO(name):
        pattern = [[\b(KEYWORDS)(\(\w*\))*:]],
      },
    },
  },

  -- Code documentation
  {
    "danymat/neogen",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.neogen_")
    end,
  },

  -- Startup menu
  {
    "goolord/alpha-nvim",
    event = { "VimEnter" },
    config = function()
      require("plugins.alpha_")
    end,
  },

  -- Mark utility
  {
    "otavioschwanck/arrow.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      { "echasnovski/mini.icons" },
    },
    opts = {
      show_icons = true,
      leader_key = "m",
      buffer_leader_key = "M",
    },
  },

  -- Icons
  {
    "echasnovski/mini.icons",
    lazy = true,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
    opts = {},
    init = function() -- Override nvim-web-devicons
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- UI for Nvim notification
  {
    "j-hui/fidget.nvim",
    opts = {},
    config = function()
      require("fidget").setup {
        notification = {
          window = {
            winblend = 0,
          },
        }
      }
    end
  },

  -- Highlight color
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    init = function()
      require("colorizer").setup()
    end
  },

  -- Vim motion helper
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          jump_labels = true
        }
      }
    },
  },

  -- Surround selections
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- Session
  {
    "folke/persistence.nvim",
    event = { "BufReadPre" }, -- this will only start session saving when an actual file was opened
    opts = {},
  },

  -- Keybindings Helper
  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    config = function()
      require("plugins.which_key_")
    end
  },

  -- Colorscheme
  {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("plugins.catpuccin_")
    end,
  },

}
