--[[
  File: neotree_.lua
  Description: Browse the file system and other tree like structures in whatever style suits you, including sidebars, floating windows, netrw split style, or all of them at once!
  Link: https://github.com/nvim-neo-tree/neo-tree.nvim
]]

local events = require("neo-tree.events")

require("neo-tree").setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = false,
  sources = {
    "filesystem",
    "buffers",
    "git_status",
  },
  source_selector = {
    winbar = true,
    statusline = false,
  },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf" },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    modified = {
      symbol = "",
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified  = "", -- or "~", but this is redundant info if you use git_status_colors on the name
        deleted   = "", -- this can only be used in the git_status source
        renamed   = "", -- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored   = "󰎂",
        unstaged  = "󰄯",
        staged    = "󰄳",
        conflict  = "󰅙",
      },
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    file_size = {
      enabled = false,
      required_width = 50, -- min width of window required to show this column
    },
    type = {
      enabled = false,
      required_width = 70, -- min width of window required to show this column
    },
    last_modified = {
      enabled = false,
      required_width = 90, -- min width of window required to show this column
    },
    created = {
      enabled = false,
      required_width = 110, -- min width of window required to show this column
    },
    symlink_target = {
      enabled = true,
    },
  },
  window = {
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ["fi"] = function() vim.api.nvim_exec2("Neotree focus filesystem left", { output = true }) end,
      ["bu"] = function() vim.api.nvim_exec2("Neotree focus buffers left", { output = true }) end,
      ["gi"] = function() vim.api.nvim_exec2("Neotree focus git_status left", { output = true }) end,
      ["b"] = "noop",
    },
  },
  filesystem = {
    bind_to_cwd = true,
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  buffers = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    group_empty_dirs = false, -- when true, empty folders will be grouped together
    show_unloaded = false,
  },
  event_handlers = {
    {
      event = events.FILE_OPENED,
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end
    },
  },
  events = {
    {
      event = events.FILE_RENAMED,
      handler = function(args)
        -- fix references to file
        print(args.source, " renamed to ", args.destination)
      end
    },
    {
      event = events.FILE_MOVED,
      handler = function(args)
        -- fix references to file
        print(args.source, " moved to ", args.destination)
      end
    },
  }
}
