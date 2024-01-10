--[[
  File: plugins.lua
  Description: This file needed for loading plugin list into lazy.nvim and loading plugins
  Info: Use <zo> and <zc> to open and close foldings
  See: https://github.com/folke/lazy.nvim
]]

require("helpers/globals")

return {

  -- LSP-Zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    lazy = false,
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("extensions.mason")
    end
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("extensions.treesitter")
    end
  },

  -- Completions
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "rafamadriz/friendly-snippets",
      "lukas-reineke/cmp-under-comparator",
      "ray-x/cmp-treesitter",
      "onsails/lspkind-nvim",
    },
    config = function()
      require("extensions.cmp")
    end
  },

  -- Formatters
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("extensions.conform")
    end
  },

  -- Linters
  {
    "mfussenegger/nvim-lint",
    dependencies = {
      "williamboman/mason.nvim",
      "rshkarin/mason-nvim-lint",
    },
    config = function()
      require("extensions.lint")
    end
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
  },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("extensions.lualine")
    end
  },

  -- New UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("extensions.noice")
    end
  },

  -- Code folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("extensions.nvim-ufo")
    end
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("extensions.gitsigns")
    end
  },

  -- VSCode like winbar
  {
    "utilyre/barbecue.nvim",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("extensions.barbecue")
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("extensions.bufferline")
    end,
  },

  -- Words highlighting
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure()
    end,
  },

  -- Highlight arguments
  {
    "m-demare/hlargs.nvim",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("hlargs").setup()
    end
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("extensions.neotree")
    end
  },

  -- Fuzzy finder and more
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ahmedkhalf/project.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      require("extensions.telescope")
    end
  },

  -- Note management
  {
    "renerocksai/telekasten.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "renerocksai/calendar-vim",
    },
    config = function()
      require("extensions.telekasten")
    end
  },

  -- Keybindings Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      opt.timeout = true
      opt.timeoutlen = 500
    end,
    config = function()
      require("extensions.which-key")
    end
  },

  -- Startup menu
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.alpha")
    end,
  },

  -- Session Manager
  {
    "Shatur/neovim-session-manager",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("extensions.session-manager")
    end,
  },

  -- Copy/paste manager
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("extensions.neoclip")
    end,
  },

  -- Outer pair highlight
  {
    "utilyre/sentiment.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
    },
    init = function()
      g.loaded_matchparen = 1
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_check_bracket_line = true,
      check_ts = true,
    }
  },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Peek lines
  {
    "nacro90/numb.nvim",
    config = function()
      require("numb").setup()
    end,
  },

  -- Split/join code blocks
  {
    "Wansmer/treesj",
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
    lazy = false,
    opts = {},
  },

  -- Docstrings
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("extensions.neogen")
    end
  },

  -- Colorscheme
  {
    "loctvl842/monokai-pro.nvim",
    config = function()
      require("extensions.colorscheme.monokai")
    end
  },

}
