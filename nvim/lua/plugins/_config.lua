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
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("plugins.cmp_")
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspInstall", "LspStart" },
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
    },
    config = function()
      require("plugins.lsp_")
    end,
  },

  -- Suspend/Resume LSP clients
  {
    "zeioth/garbage-day.nvim",
    lazy = true,
    dependencies = "neovim/nvim-lspconfig",
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPre",
    build = ":TSUpdateSync",
    config = function()
      require("plugins.treesitter_")
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    config = function()
      require("plugins.conform_")
    end
  },

  -- UI
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/noice.nvim",
    lazy = false,
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
    config = function ()
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

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
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
    opts = {},
  },

  -- VSCode like winbar
  {
    "utilyre/barbecue.nvim",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
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
    event = { "BufReadPre", "BufNewFile", "BufNew" },
  },

  -- Highlight arguments
  {
    "m-demare/hlargs.nvim",
    event = { "BufReadPre", "BufNewFile", "BufNew" },
    dependencies = { "nvim-treesitter" },
  },

  -- Highlighting Words
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPre", "BufNewFile", "BufNew" },
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

  -- Indent Guide
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.hlchunk_")
    end
  },

  -- Code folding
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("plugins.ufo_")
    end,
  },

  -- Split/join code blocks
  {
    "Wansmer/treesj",
    event = { "BufReadPost", "BufNewFile", "BufNew" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.treesj_")
    end,
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
    event = { "BufReadPost", "BufNewFile", "BufNew" },
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
    dependencies = {
      { "echasnovski/mini.icons" },
    },
    opts = {
      show_icons = true,
      leader_key = ";",
      buffer_leader_key = "m",
    }
  },

  -- Icons
  {
    "echasnovski/mini.icons",
    opts = {},
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

  -- Colorscheme
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("config.colorscheme")
    end,
  },

}
