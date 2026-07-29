-- Fuzzy finder powered by fzf
plugin.add({
  name = "fzf_lua",
  src = "https://github.com/ibhagwan/fzf-lua",
  -- Every entry point is one of these keys or a `deps = { "fzf_lua" }` consumer
  -- (03-tiny-code-action), so there is nothing to do at startup.
  keys = {
    { "<leader>O",  desc = "Show recent files" },
    { "<leader>o",  desc = "Search for a file" },
    { "<leader>i",  desc = "Go to previous location" },
    { "<leader>gr", desc = "Find string in project" },
    { "<leader>b",  desc = "Show all buffers" },
    { "<leader>gt", desc = "Grep todos" },
  },
  config = function()
    -- Configure fzf_lua
    local fzf_lua = require("fzf-lua")

    fzf_lua.setup({
      "fzf-native",
      fzf_colors = true, -- derive from current colorscheme (adapts to dark/light)
      ui_select = false, -- let snacks.picker own vim.ui.select; avoids a
      -- duplicate-registration warning at startup (which the ext_messages UI
      -- surfaces as a blocking "Press any key to continue" dialog).
      file_icon_padding = " ",
      winopts = {
        preview    = {
          default = "bat",
          wrap    = true,
          winopts = {
            signcolumn = "yes",
          },
        },
        -- split = "belowright new" -- open in split right of current window
        height     = 0.85, -- window height
        width      = 0.80, -- window width
        row        = 0.35, -- window row position (0=top, 1=bottom)
        col        = 0.50, -- window col position (0=left, 1=right)
        backdrop   = 70,   -- 0 is fully opaque, 100 is fully transparent
        treesitter = {
          enabled    = true,
          fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
        },
      },
      fzf_opts = {
        ["--cycle"] = true,
      },
      oldfiles = {
        include_current_session = true,
        stat_file = true, -- verify files exist on disk
      },
      previewers = {
        builtin = {
          syntax_limit_b = 1024 * 1000, -- 1MB
        },
      },
      grep = {
        resume         = true,                                         -- resume last search
        rg_opts        = "--sort-files --hidden --column --line-number --no-heading " ..
            "--color=always --smart-case -g '!{.git,node_modules}/*'", -- sort results (to be always in the same order, may impact perf)
        rg_glob        = true,                                         -- enable glob parsing so queries can include globs
        glob_flag      = "--iglob",                                    -- case-insensitive glob; use '--glob' for case-sensitive
        glob_separator = "%s%-%-",                                     -- split query from glob at ' --' (e.g. "foo -- --iglob=*.lua")
      },
    })

    -- Add keymap
    utils.wk_add({
      { "<leader>O",    function() fzf_lua.oldfiles() end,                         desc = "Show recent files",       mode = "n" },
      { "<leader>o",    function() fzf_lua.files() end,                            desc = "Search for a file",       mode = "n" },
      { "<leader>i",    function() fzf_lua.jumps() end,                            desc = "Go to previous location", mode = "n" },
      { "<leader>gr",   function() fzf_lua.live_grep({ multiprocess = true }) end, desc = "Find string in project",  mode = "n" },
      { "<leader>b",    function() fzf_lua.buffers() end,                          desc = "Show all buffers",        mode = "n" },
      -- Not <leader>todo: that prefix shadows <leader>to / <leader>tO (neotest
      -- output) and made the whole <leader>t namespace wait on timeoutlen.
      { "<leader>gt",   "<cmd>TodoFzf<cr>",                                        desc = "Grep todos",              mode = "n" },
    })
  end,
})
