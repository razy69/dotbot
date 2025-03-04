--[[
  File: plugins.lua
  Description: This file needed for loading plugin list into lazy.nvim and loading plugins
  Info: Use <zo> and <zc> to open and close foldings
  See: https://github.com/folke/lazy.nvim
]]

require("helpers/globals")

return {

  -- Indentation Highlighting {{{
  {
    "lukas-reineke/indent-blankline.nvim",
  },
  -- }}}

  -- Rainbow delimiters {{{
  {
    "HiPhish/rainbow-delimiters.nvim",
  },
  -- }}}

  -- Theme Monokai {{{
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("extensions.colorscheme.monokai")
    end
  },
  -- }}}

  -- Mason {{{
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
  -- }}}

  -- Noice {{{
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
  -- }}}

  -- TreeSitter {{{
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("extensions.treesitter")
    end
  },
  -- }}}

  -- Lualine {{{
  {
    "nvim-lualine/lualine.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew", },
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("extensions.lualine")
    end
  },
  -- }}}

  -- Neo Tree {{{
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
  -- }}}

  -- CMP {{{
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
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "rafamadriz/friendly-snippets",
      "lukas-reineke/cmp-under-comparator",
    },
    config = function()
      require("extensions.cmp")
    end
  },
  -- }}}

  -- LSP Kind {{{
  {
    "onsails/lspkind-nvim",
    config = function()
      require("extensions.lspkind-conf")
    end
  },
  -- }}}

  -- Telescope {{{
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
  -- }}}

  -- Telekasten
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
  -- }}}

  -- Git Signs {{{
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("extensions.gitsigns")
    end
  },
  -- }}}

  -- Which-Key {{{
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
  -- }}}

  -- Alpha Nvim {{{
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("extensions.alpha")
    end,
  },
  -- }}}

  -- Neovim Session Manager {{{
  {
    "Shatur/neovim-session-manager",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("extensions.session-manager")
    end,
  },
  -- }}}

  -- Neoclip {{{
  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("extensions.neoclip")
    end,
  },
  -- }}}

  -- Barbecue {{{
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
  -- }}}

  -- Bufferline {{{
  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("extensions.bufferline")
    end,
  },
  -- }}}

  -- Vim Illuminate {{{
  {
    "RRethy/vim-illuminate",
    config = function()
      require("illuminate").configure()
    end,
  },
  -- }}}

  -- hlargs {{{
  {
    "m-demare/hlargs.nvim",
    config = function()
      require("hlargs").setup()
    end
  },
  -- }}}

  -- trim.nvim {{{
  {
    "cappyzawa/trim.nvim",
    opts = {}
  },
  -- }}}

  -- nvim-autopairs {{{
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  -- }}}

  -- sentiment.nvim {{{
  {
    "utilyre/sentiment.nvim",
    version = "*",
    event = "VeryLazy", -- keep for lazy loading
    opts = {
      -- config
    },
    init = function()
      -- `matchparen.vim` needs to be disabled manually in case of lazy loading
      vim.g.loaded_matchparen = 1
    end,
  },
  -- }}}

  -- Pretty Fold {{{
  {
    "anuvyklack/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup({
        fill_char = "-",
      })
    end,
  },
  -- }}}
}
