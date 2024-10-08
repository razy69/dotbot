--[[
  File: neotree.lua
  Description: Configuration NeoTree
  See: https://github.com/nvim-neo-tree/neo-tree.nvim
]]

local neotree = require("neo-tree")

neotree.setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = false,
  open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
  default_component_configs = {
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
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    file_size = {
      enabled = true,
      required_width = 50, -- min width of window required to show this column
    },
    type = {
      enabled = true,
      required_width = 70, -- min width of window required to show this column
    },
    last_modified = {
      enabled = true,
      required_width = 90, -- min width of window required to show this column
    },
    created = {
      enabled = true,
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
      ["e"] = function() api.nvim_exec("Neotree focus filesystem left", true) end,
      ["b"] = function() api.nvim_exec("Neotree focus buffers left", true) end,
      ["g"] = function() api.nvim_exec("Neotree focus git_status left", true) end,
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
  },
  buffers = {
    follow_current_file = {
      enabled = true,
    },
    group_empty_dirs = true, -- when true, empty folders will be grouped together
    show_unloaded = true,
  },
  event_handlers = {
    {
      event = "file_opened",
      handler = function(file_path)
        require("neo-tree.command").execute({ action = "close" })
      end
    },
  },
  events = {
    {
      event = "file_renamed",
      handler = function(args)
        -- fix references to file
        print(args.source, " renamed to ", args.destination)
      end
    },
    {
      event = "file_moved",
      handler = function(args)
        -- fix references to file
        print(args.source, " moved to ", args.destination)
      end
    },
  }
}
