--[[
  File: plugins.lua
  Description: This file needed for loading plugin list into lazy.nvim and loading plugins
  Info: Use <zo> and <zc> to open and close foldings
  See: https://github.com/folke/lazy.nvim
]]

require("globals")

return {

  -- Lua functions library
	{
    "nvim-lua/plenary.nvim",
    lazy = false,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("extensions.lsp")
    end,
  },

  -- Suspend/Resume LSP clients
  {
    "zeioth/garbage-day.nvim",
    lazy = true,
    dependencies = "neovim/nvim-lspconfig",
  },

  -- Completions
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "FelipeLema/cmp-async-path",
      "petertriho/cmp-git",
      "lukas-reineke/cmp-under-comparator",
      "ray-x/cmp-treesitter",
      "onsails/lspkind-nvim",
    },
    config = function()
      require("extensions.cmp")
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPre",
    dependencies = { "haringsrob/nvim_context_vt" },
    build = ":TSUpdateSync",
    config = function()
      require("extensions.treesitter")
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    cmd = "Trouble",
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    config = function()
      require("extensions.conform_")
    end
  },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.lualine_")
    end,
  },

  -- UI
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("extensions.noice_")
    end,
  },

  -- VSCode like winbar
  {
    "utilyre/barbecue.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("extensions.barbecue_")
    end,
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("extensions.gitsigns_")
    end,
  },

  -- Refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },

  -- Close buffers if too old
  {
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    config = true,
  },

  -- Better movements
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true
        }
      }
    },
  },

  -- Code folding
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("extensions.ufo_")
    end,
  },

  -- Indentation highlighting
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("extensions.indent-blankline")
    end,
    main = "ibl",
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPre", "BufNewFile", "BufNew" },
  },

  -- Words highlighting
  {
    "RRethy/vim-illuminate",
    lazy = true,
    config = function()
      require("illuminate").configure({
        filetypes_denylist = {
          "dirbuf",
          "dirvish",
          "fugitive",
          "neo-tree",
        },
      })
    end,
  },

  -- Highlight arguments
  {
    "m-demare/hlargs.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("hlargs").setup()
    end,
  },

  -- Jump to outer node smartly
  {
    "Mr-LLLLL/treesitter-outer",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = "nvim-treesitter/nvim-treesitter",
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {
      enable_check_bracket_line = true,
      check_ts = true,
    }
  },

  -- Peek lines
  {
    "nacro90/numb.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    config = function()
      require("numb").setup()
    end,
  },

  -- Split/join code blocks
  {
    "Wansmer/treesj",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({
        max_join_length = 1000,
      })
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    init = function()
      require("Comment").setup()
    end,
  },

  -- Docstrings
  {
    "danymat/neogen",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("extensions.neogen_")
    end,
  },

  -- Startup menu
  {
    "goolord/alpha-nvim",
    event = { "VimEnter" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.alpha_")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("extensions.neotree")
    end,
  },

  -- Fuzzy finder and more
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      "debugloop/telescope-undo.nvim",
      "ThePrimeagen/refactoring.nvim",
    },
    config = function()
      require("extensions.telescope_")
    end,
  },

  -- Diff tools
  {
    "akinsho/git-conflict.nvim",
    lazy = true,
    version = "*",
    config = true,
  },
  {
    "sindrets/diffview.nvim",
    lazy = true,
  },

  -- Note management
  {
    "renerocksai/telekasten.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
    config = function()
      require("extensions.telekasten_")
    end,
  },

  -- Keybindings Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  -- Markdown
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "telekasten" },
        latex = { enabled = false },
        heading = {
          icons = { " 󰉫 ", " 󰉬 ", " 󰉭 ", " 󰉮 ", " 󰉯 ", " 󰉰 " },
          position = "inline",
        },
        checkbox = {
          unchecked = { icon = "  " },
          checked = { icon = "  " },
        },
      })
    end,
  },

  -- Utils
  {
    "max397574/better-escape.nvim",
    lazy = false,
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Colorschemes
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("tiny-devicons-auto-colors").setup()
    end
  },

  {
    "catppuccin/nvim",
    lazy = true,
    config = function()
      require("colorschemes.catppuccin")
    end,
  },

}
