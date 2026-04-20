-- Collection of small QoL plugins (dashboard, notifier, scroll, bigfile, statuscolumn)
plugin.add({
  name = "snacks",
  src = "https://github.com/folke/snacks.nvim",
  config = function()
    -- Configure snacks
    local snacks = require("snacks")
    snacks.setup({
      bigfile = { enabled = true },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        icons = {
          git = {
            added     = "",
            deleted   = "󰅙",
            modified  = "",
            renamed   = "",
            untracked = "",
            ignored   = "󰎂",
            staged    = "󰄳",
            unmerged  = "",
          },
        },
        sources = {
          explorer = {
            auto_close = true,
            win = {
              list = {
                keys = {
                  ["S"] = "edit_split",
                  ["s"] = "edit_vsplit",
                  ["t"] = "tab"
                },
              },
            },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                vim.cmd("cd " .. vim.fn.stdpath("config"))
                snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
              end
            },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        },
      },
      image = { enabled = true },
      notifier = {
        enabled = true,
        top_down = true,
      },
      terminal = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = {
          open = false,
          git_hl = false,
        },
        refresh = 50,
      },
    })

    -- Add keymap
    utils.wk_add({
      { "<leader>e",  function() snacks.explorer() end,                                           desc = "Toggle Explorer", mode = "n" },
      { "<C-\\>",     function() snacks.terminal() end,                                           desc = "Toggle Terminal", mode = { "n", "t" } },
      { "<leader>gg", function() snacks.terminal("lazygit", { cwd = snacks.git.get_root() }) end, desc = "Lazygit",         mode = "n" },
    })

    -- Per-project ShaDa file: stores marks, registers, etc. scoped to each git repo
    -- so jumping between projects doesn't pollute each other's state.
    do
      local data = tostring(vim.fn.stdpath("data"))
      local git_root = require("snacks.git").get_root()
      local cwd = git_root or vim.fn.getcwd()
      local file = vim.fs.joinpath(data, "project_shada", vim.base64.encode(cwd))
      vim.fn.mkdir(vim.fs.dirname(file), "p")
      vim.opt.shadafile = file
    end
  end,
})
