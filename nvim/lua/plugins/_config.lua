--[[
  File: _config.lua
  Description: Plugins list.
  See: https://github.com/folke/lazy.nvim
]]

local lazyFile = { "BufReadPost", "BufNewFile", "BufWritePre" }

return {
  -- Completions
  {
    "saghen/blink.cmp",
    event = { "InsertEnter" },
    version = "*",
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
    event = lazyFile,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("plugins.lsp_")
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = lazyFile,
    lazy = vim.fn.argc(-1) == 0,
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
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
        func_map = { vsplit = "s" },
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
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("plugins.neotree_")
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("plugins.trouble_")
    end
  },

  -- VSCode like winbar
  -- TODO: replace plugin, archived on Jan 9, 2025.
  {
    "utilyre/barbecue.nvim",
    event = lazyFile,
    dependencies = { "SmiteshP/nvim-navic" },
    config = function()
      require("plugins.barbecue_")
    end,
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = lazyFile,
  },

  -- Highlight arguments
  {
    "m-demare/hlargs.nvim",
    event = lazyFile,
    dependencies = { "nvim-treesitter" },
  },

  -- Highlighting Words
  {
    "RRethy/vim-illuminate",
    event = lazyFile,
    config = function()
      require("plugins.illuminate_")
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.gitsigns_")
    end,
  },

  -- Indent Guide
  {
    "lukas-reineke/indent-blankline.nvim",
    event = lazyFile,
    main = "ibl",
    config = function()
      require("plugins.ibl_")
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
    event = lazyFile,
  },

  -- Markdown
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.markdown_")
    end,
  },

  -- Help view
  {
    "OXY2DEV/helpview.nvim",
    ft = "help",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = lazyFile,
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
    event = lazyFile,
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
    event = lazyFile,
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      show_icons = true,
      leader_key = "M",
      buffer_leader_key = "m",
    },
  },

  -- Icons
  {
    "echasnovski/mini.icons",
    lazy = true,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
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
    config = function()
      require("fidget").setup({
        notification = {
          window = {
            winblend = 0,
          },
        }
      })
    end
  },

  -- Highlight color
  {
    "norcalli/nvim-colorizer.lua",
    event = lazyFile,
    init = function()
      require("colorizer").setup { "css", "javascript", "html", "tmux" }
    end
  },

  -- Vim motion helper
  {
    "folke/flash.nvim",
    event = lazyFile,
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
    event = lazyFile,
    version = "*",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- Session
  {
    "folke/persistence.nvim",
    event = { "BufReadPre" }, -- this will only start session saving when an actual file was opened
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
      require("plugins.catppuccin_")
    end,
  },

}
