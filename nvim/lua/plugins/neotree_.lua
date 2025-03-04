--[[
  File: neotree_.lua
  Description: Configuration NeoTree
  See: https://github.com/nvim-neo-tree/neo-tree.nvim
]]

local events = require("neo-tree.events")

require("neo-tree").setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = false,
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf" },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
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
      ["e"] = function() vim.api.nvim_exec("Neotree focus filesystem left", true) end,
      ["b"] = function() vim.api.nvim_exec("Neotree focus buffers left", true) end,
      ["g"] = function() vim.api.nvim_exec("Neotree focus git_status left", true) end,
    },
  },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
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
      event = events.FILE_OPENED,
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end
    },
    {
      event = events.NEO_TREE_BUFFER_ENTER,
      handler = function()
        -- Cursor hide
        local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
        hl.blend = 100
        vim.api.nvim_set_hl(0, "Cursor", hl)
        vim.opt.guicursor:append("a:Cursor/lCursor")
      end
    },
    {
      event = events.NEO_TREE_BUFFER_LEAVE,
      handler = function()
        -- Cursor show
        local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
        hl.blend = 0
        vim.api.nvim_set_hl(0, "Cursor", hl)
        vim.opt.guicursor:remove("a:Cursor/lCursor")
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
