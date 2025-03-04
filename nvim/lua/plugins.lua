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
    dependencies = {
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "ray-x/cmp-treesitter",
      "FelipeLema/cmp-async-path",
      "petertriho/cmp-git",
      "lukas-reineke/cmp-under-comparator",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
    },
    config = function()
      require("extensions.cmp")
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPre",
    build = ":TSUpdateSync",
    config = function()
      require("extensions.treesitter")
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    config = function()
      require("extensions.conform_")
    end
  },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
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
    lazy = false,
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
    cmd = "Refactor",
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
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    config = true,
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

  -- Hlchunk
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("extensions.hlchunk_")
    end
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPre", "BufNewFile", "BufNew" },
  },

  -- Words highlighting
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPre", "BufNewFile", "BufNew" },
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
    event = { "BufReadPre", "BufNewFile", "BufNew" },
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
    cmd = "Telescope",
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
    cmd = "DiffviewOpen",
  },

  -- Note management
  {
    "renerocksai/telekasten.nvim",
    cmd = "Telekasten",
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
    ft = { "markdown", "telekasten" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("extensions.markdown_")
    end,
  },

  -- Utils
  {
    "max397574/better-escape.nvim",
    lazy = true,
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Smooth scroll
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({})
    end,
  },

  -- Readline Bindings
  {
    "assistcontrol/readline.nvim",
    lazy = true,
  },

  -- Help view
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
  },

  -- Colorschemes
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      local theme_colors = require("catppuccin.palettes").get_palette("frappe")
      require("tiny-devicons-auto-colors").setup({
        autoreload = true,
        colors = theme_colors,
        cache = {
          enabled = true,
          path = vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors-cache.json",
        },
      })
    end
  },
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("colorschemes.catppuccin")
    end,
  },

}
