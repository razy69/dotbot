--[[
  File: plugins.lua
  Description: This file needed for loading plugin list into lazy.nvim and loading plugins
  Info: Use <zo> and <zc> to open and close foldings
  See: https://github.com/folke/lazy.nvim
]]

require("helpers/globals")

return {

  -- LSP
  {
    "williamboman/mason.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvimtools/none-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function ()
      require("extensions.lsp")
    end,
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

  -- Suspend/Resume LSP clients
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("extensions.treesitter")
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- branch = "dev",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    opts = {},
  },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.lualine")
    end,
  },

  -- Notifications
  {
    "j-hui/fidget.nvim",
    config = function ()
      require("extensions.fidget")
    end,
  },

  {
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("extensions.noice")
		end,
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("extensions.gitsigns")
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
      require("extensions.barbecue")
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.bufferline")
    end,
  },

  -- Code folding
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("extensions.nvim-ufo")
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
    event = { "BufReadPost", "BufNewFile", "BufNew" },
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
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "nvim-treesitter" },
    config = function()
      require("hlargs").setup()
    end,
  },

  -- Jump to outer node smartly
  {
    "Mr-LLLLL/treesitter-outer",
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
    init = function()
      require("Comment").setup()
    end,
  },

  -- Docstrings
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("extensions.neogen")
    end,
  },

  -- Smooth scroll
  {
    "karb94/neoscroll.nvim",
    config = function ()
      require("neoscroll").setup({})
    end,
  },

  -- Startup menu
  {
    "goolord/alpha-nvim",
    event = { "VimEnter" },
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
    end,
  },

  -- Fuzzy finder and more
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ahmedkhalf/project.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-media-files.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      require("extensions.telescope")
    end,
  },

  -- Find / Replace
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Note management
  {
    "renerocksai/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
    config = function()
      require("extensions.telekasten")
    end,
  },

  -- Keybindings Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.timeout = true
      vim.opt.timeoutlen = 500
    end,
    config = function()
      require("extensions.which-key")
    end,
  },

  -- Colorschemes
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   lazy = false,
  --   config = function()
  --     require("colorschemes.monokai")
  --   end,
  --   priority = 1000,
  -- },

  {
    "catppuccin/nvim",
    lazy = false,
    config = function ()
      require("colorschemes.catppuccin")
    end,
    priority = 1000,
  },

}
