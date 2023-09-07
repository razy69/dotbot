--[[
  File: plugins.lua
  Description: This file needed for loading plugin list into lazy.nvim and loading plugins
  Info: Use <zo> and <zc> to open and close foldings
  See: https://github.com/folke/lazy.nvim
]]

require("helpers/globals")

return {

-- LSP [[

  -- LSP-Zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    config = function()
      require("extensions.lspzero")
    end
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
      "mhartington/formatter.nvim",
      "mfussenegger/nvim-lint",
    },
    config = function()
      require("extensions.mason")
    end
  },
-- ]]

-- Autocompletion [[
  -- nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    build = "make install_jsregexp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "rafamadriz/friendly-snippets",
      "lukas-reineke/cmp-under-comparator",
      "f3fora/cmp-spell",
      "ray-x/cmp-treesitter",
      "onsails/lspkind-nvim",
    },
    config = function()
      require("extensions.cmp")
    end
  },
-- ]]

-- Syntax [[
  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("extensions.treesitter")
    end
  },
-- ]]

-- Formatter [[
  -- formatter.nvim
  {
    "mhartington/formatter.nvim",
    lazy = true,
    config = function()
      require("extensions.formatter")
    end
  },

  -- trim.nvim
  {
    "cappyzawa/trim.nvim",
    opts = {}
  },
-- ]]

-- Linter [[
  -- nvim-lint
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    config = function()
      require("extensions.lint")
    end
  },
-- ]]

-- Visual [[
  -- Theme Monokai
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("extensions.colorscheme.monokai")
    end
  },

  -- Indentation Highlighting
  {
    "lukas-reineke/indent-blankline.nvim",
	  branch = "v3",
    config = function ()
      require("extensions.indent-blankline")
     end
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
  },

  -- Lualine (statusbar)
  {
    "nvim-lualine/lualine.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew", },
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("extensions.lualine")
    end
  },

  -- Noice
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

  -- Nvim-UFO
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function ()
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

  -- Dropbar
  -- {
  --   "Bekaboo/dropbar.nvim"
  -- },

  -- Barbecue
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

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("extensions.bufferline")
    end,
  },

  -- Vim Illuminate
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure()
    end,
  },

  -- hlargs (highlight arg def and usage uwin treesitter)
  {
    "m-demare/hlargs.nvim",
    dependencies = {"nvim-treesitter"},
    config = function()
      require("hlargs").setup()
    end
  },
-- ]]

-- Features [[
  -- Neo Tree (file explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function ()
      require("extensions.neotree")
    end
  },

  -- Telescope (fuzzy finder and more)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    lazy = true,
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

  -- Telekasten (note management)
  {
    "renerocksai/telekasten.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "renerocksai/calendar-vim",
    },
    config = function()
      require("extensions.telekasten")
    end
  },

  -- Which-Key (help)
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

  -- Alpha Nvim (startup menu)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.alpha")
    end,
  },

  -- Neovim Session Manager (manage vim sessions)
  {
    "Shatur/neovim-session-manager",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("extensions.session-manager")
    end,
  },

  -- Neoclip (copy/paste manager)
  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("extensions.neoclip")
    end,
  },

  -- sentiment.nvim
  {
    "utilyre/sentiment.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
    },
    init = function()
      vim.g.loaded_matchparen = 1
    end,
  },

  -- nvim-autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_check_bracket_line = false,
      check_ts = true,
    }
  },

  -- better-escape.nvim
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- numb.nvim
  {
    "nacro90/numb.nvim",
    config = function ()
      require("numb").setup()
    end,
  },

  -- treesj
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({})
    end,
  },

  -- Comment.nvim
  {
    "numToStr/Comment.nvim",
    lazy = false,
    opts = {},
  },

  -- Neogen
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function ()
      require("extensions.neogen")
    end
  }

-- ]]
}
