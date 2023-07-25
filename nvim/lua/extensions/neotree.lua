--[[
  File: neotree.lua
  Description: Configuration NeoTree
  See: https://github.com/nvim-neo-tree/neo-tree.nvim
]]

local neotree = require("neo-tree")

cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

fn.sign_define("DiagnosticSignError",
{text = "", texthl = "DiagnosticSignError"})
fn.sign_define("DiagnosticSignWarn",
{text = "", texthl = "DiagnosticSignWarn"})
fn.sign_define("DiagnosticSignInfo",
{text = "", texthl = "DiagnosticSignInfo"})
fn.sign_define("DiagnosticSignHint",
{text = "", texthl = "DiagnosticSignHint"})

neotree.setup{
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
        deleted   = "",-- this can only be used in the git_status source
        renamed   = "",-- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored   = "",
        unstaged  = "●",
        staged    = "●",
        conflict  = "",
      },
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
    },
  },
  name = {
    trailing_slash = true,
    use_git_status_colors = true,
    highlight = "NeoTreeFileName",
  },
  window = {
    width = 40,
    mapping_options = {
      noremap = true,
      nowait = true,
    },
    mappings = {
      ["<cr>"] = "open",
      ["h"] = "close_node",
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
    follow_current_file = true,
    use_libuv_file_watcher = true,
  },
  buffers = {
    follow_current_file = true, -- This will find and focus the file in the active buffer every
                                -- time the current file is changed while the tree is open.
    group_empty_dirs = true,    -- when true, empty folders will be grouped together
    show_unloaded = true,
  },
  event_handlers = {
    {
      event = "file_open_requested",
      handler = function(file_path)
        --auto close
        require("neo-tree").close_all()
      end
    },
    {
      event = "neo_tree_window_after_open",
      handler = function(args)
        if args.position == "left" or args.position == "right" then
          vim.cmd("wincmd =")
        end
      end
    },
    {
      event = "neo_tree_window_after_close",
      handler = function(args)
        if args.position == "left" or args.position == "right" then
          vim.cmd("wincmd =")
        end
      end
    },
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
  },
}
