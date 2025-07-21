--[[
  File: _config.lua
  Description: Plugins list.
  See: https://github.com/folke/lazy.nvim
]]

local lazyFile = { "BufReadPost", "BufNewFile", "BufWritePre" }

return {
  -- LuaLS config for neovim
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Terragrunt LS
  {
    "gruntwork-io/terragrunt-ls",
    -- To use a local version of the Neovim plugin, you can use something like following:
    -- dir = vim.fn.expand '~/repos/src/github.com/gruntwork-io/terragrunt-ls',
    ft = "hcl",
    config = function()
      local terragrunt_ls = require("terragrunt-ls")
      terragrunt_ls.setup({})
      if terragrunt_ls.client then
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "hcl",
          callback = function()
            vim.lsp.buf_attach_client(0, terragrunt_ls.client)
          end,
        })
      end
    end,
  },

  -- Manage external editor tooling
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      {
        "Bekaboo/dropbar.nvim",
        -- optional, but required for fuzzy finder support
        dependencies = {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "make"
        },
        config = function()
          local dropbar_api = require("dropbar.api")
          vim.keymap.set("n", ";", dropbar_api.pick, { desc = "Pick symbols in winbar" })
          vim.keymap.set("n", ";p", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
          vim.keymap.set("n", ";n", dropbar_api.select_next_context, { desc = "Select next context" })
        end
      },
    },
    config = function()
      require("plugins.mason_")
    end
  },

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

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = lazyFile,
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter_")
    end,
  },

  -- Debugger
  {
    "rcarriga/nvim-dap-ui",
    event = { "VeryLazy" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.set_log_level("WARN")
      dapui.setup({})

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        delve = {
          detached = false,
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
    config = function()
      require("dap-python").setup("uv")
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = { "VeryLazy" },
    opts = {},
  },

  -- Test
  {
    "nvim-neotest/neotest",
    event = { "VeryLazy" },
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      "andythigpen/nvim-coverage", -- Added dependency
      {
        "fredrikaverpil/neotest-golang",
        dependencies = {
          "leoluz/nvim-dap-go",
        },
      },
    },
    config = function()
      local neotest_golang_opts = { -- Specify configuration
        runner = "go",
        go_test_args = {
          "-v",
          "-race",
          "-count=1",
          "-coverprofile=" .. vim.fn.getcwd() .. "/.coverage",
        },
      }
      require("neotest").setup({
        adapters = {
          require("neotest-golang")(neotest_golang_opts),
        },
      })
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = lazyFile,
    keys = {
      { "<leader>f", "<cmd>Format<cr>", desc = "Format buffer", mode = "n" },
    },
    config = function()
      require("plugins.conform_")
    end
  },

  -- Undo Glow
  {
    "y3owk1n/undo-glow.nvim",
    event = { "VeryLazy" },
    config = function()
      require("plugins.undo_glow_")
    end
  },

  -- Improve clipboard
  {
    "EtiamNullam/deferred-clipboard.nvim",
    config = function()
      require("deferred-clipboard").setup {
        lazy = true,
        fallback = "unnamedplus", -- or your preferred setting for clipboard
      }
    end
  },

  -- Go
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp_keymaps = false,
    },
    config = function(_, opts)
      require("go").setup(opts)
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ":lua require('go.install').update_all_sync()" -- if you need to install/update all binaries
  },

  -- UI
  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("plugins.noice_")
    end,
  },

  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
    config = function()
      require("plugins.snacks_")
    end
  },

  -- Bool
  {
    "nat-418/boole.nvim",
    event = { "VeryLazy" },
    config = function()
      require("boole").setup({
        mappings = {
          increment = "<C-a>",
          decrement = "<C-x>",
        },
      })
    end
  },

  -- Undotree
  {
    "y3owk1n/time-machine.nvim",
    cmd = {
      "TimeMachineToggle",
      "TimeMachinePurgeBuffer",
      "TimeMachinePurgeAll",
      "TimeMachineLogShow",
      "TimeMachineLogClear",
    },
    opts = {},
    keys = {
      {
        "<leader>wt",
        "<cmd>TimeMachineToggle<cr>",
        desc = "[W]ayback Time Machine [t]oggle",
      },
      {
        "<leader>wp",
        "<cmd>TimeMachinePurgeCurrent<cr>",
        desc = "[W]ayback Time Machine [p]urge current",
      },
      {
        "<leader>wP",
        "<cmd>TimeMachinePurgeAll<cr>",
        desc = "[W]ayback Time Machine [P]urge all",
      },
      {
        "<leader>wl",
        "<cmd>TimeMachineLogShow<cr>",
        desc = "[W]ayback Time Machine Show [l]og",
      },
    },
  },

  -- Cursor
  { "danilamihailov/beacon.nvim" },

  -- Statusbar
  {
    "nvim-lualine/lualine.nvim",
    event = lazyFile,
    config = function()
      require("plugins.lualine_")
    end,
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    cmd = { "FzfLua" },
    config = function()
      require("plugins.fzf_lua_")
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

  -- Diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    config = function()
      require("plugins.trouble_")
    end
  },
  {
    "artemave/workspace-diagnostics.nvim",
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
    config = function()
      local utils = require("utilities.catpuccin")
      local colors = utils.get_palette()

      require("hlargs").setup({
        color = colors.maroon,
      })
    end
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
    event = { "VeryLazy" },
    config = function()
      require("plugins.gitsigns_")
    end,
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
    opts = {},
  },

  -- Markdown
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.markdown_")
    end,
  },

  -- Comments
  {
    "folke/todo-comments.nvim",
    event = lazyFile,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.todo_comments_")
    end
  },
  {
    "numToStr/Comment.nvim",
    event = lazyFile,
    opts = {},
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = lazyFile,
    opts = {},
  },

  -- Code Annotation
  {
    "danymat/neogen",
    event = lazyFile,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("plugins.neogen_")
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

  -- Highlight color
  {
    "norcalli/nvim-colorizer.lua",
    event = lazyFile,
    init = function()
      require("colorizer").setup({ "css", "javascript", "html", "tmux" })
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
    opts = {},
  },

  -- Code Action
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "ibhagwan/fzf-lua" },
    },
    event = "LspAttach",
    opts = {
      backend = "delta",
      picker = "select",
    },
  },

  -- scrolloff
  {
    "Aasim-A/scrollEOF.nvim",
    event = { "CursorMoved", "WinScrolled" },
    opts = {},
  },

  -- Notes
  {
    "nvim-neorg/neorg",
    dependencies = {
      "benlubas/neorg-interim-ls",
      "3rd/image.nvim",
    },
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("plugins.neorg_")
    end,
  },

  -- GPG
  {
    "benoror/gpg.nvim",
    ft = { "gpg" },
  },

  -- HTTP client
  {
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>Rs", desc = "Send request" },
      { "<leader>Ra", desc = "Send all requests" },
      { "<leader>Rb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      global_keymaps = false,
      global_keymaps_prefix = "<leader>R",
      kulala_keymaps_prefix = "",
    },
  },

  -- Super sort
  {
    "sQVe/sort.nvim",
    config = function()
      require("sort").setup({
        -- Optional configuration overrides.
      })
    end,
  },

  -- Detect file indentation
  {
    "NMAC427/guess-indent.nvim",
    event = lazyFile,
    config = function()
      require("guess-indent").setup({})
    end
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
    lazy = false,
    priority = 10000,
    config = function()
      require("plugins.catppuccin_")
    end,
  },
}
