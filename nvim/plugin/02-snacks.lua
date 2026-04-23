-- Collection of small QoL plugins (dashboard, notifier, scroll, bigfile,
-- statuscolumn) + arrow.nvim. Arrow lives here because the integration
-- (explorer decoration, dashboard section, project-wide picker) pulls
-- against snacks internals.

-- Format explorer items with an arrow mark indicator after the filename.
-- Setting item.comment hands the indicator to the built-in file
-- formatter's comment slot so it renders to the right of the filename
-- without disturbing the tree gutter alignment.
local function explorer_format(item, picker)
  if item.file and not item.dir then
    local ok, ap = pcall(require, "neonvim.arrow_project")
    if ok then
      local kind = ap.has_mark(item.file)
      if kind == "both" then
        item.comment = "󰃀 󰓾"
      elseif kind == "file" then
        item.comment = "󰃀"
      elseif kind == "lines" then
        item.comment = "󰓾"
      else
        item.comment = nil
      end
    end
  end
  return require("snacks.picker.format").file(item, picker)
end

plugin.add({
  name = "snacks",
  src = "https://github.com/folke/snacks.nvim",
  config = function()
    -- Configure snacks
    local snacks = require("snacks")

    -- Register named dashboard section BEFORE setup so it resolves by
    -- name below. snacks expects section = "<name>" to key into
    -- Snacks.dashboard.sections; an inline function there throws.
    Snacks.dashboard.sections.arrow_project_marks = function(opts)
      return require("neonvim.arrow_project").dashboard_items({ limit = (opts and opts.limit) or 5 })
    end

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
            format = explorer_format,
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
            { icon = "󰃀 ", key = "m", desc = "Project Marks", action = function() require("neonvim.arrow_project").pick() end },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { icon = "󰃀 ", title = "Project Marks", section = "arrow_project_marks", indent = 2, padding = 1 },
        },
      },
      image = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        top_down = true,
      },
      terminal = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = {
        enabled = true,
        -- Left: diagnostics + (extmark) signs, including arrow's bookmark sign.
        -- Right: git diff takes priority over folds — snacks only shows one
        -- sign per side per line, and iterating this list picks the first
        -- matching type. With fold first, a folded line hid the diff marker.
        left = { "mark", "sign" },
        right = { "git", "fold" },
        folds = {
          open = true,    -- show the ▾/▸ icon on open folds, not just closed ones
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

-- Arrow.nvim: file + line bookmarks. Loads eagerly so ArrowUpdate /
-- ArrowMarkUpdate autocmds fire during startup and the arrow_project
-- side-car index stays current from the first buffer read — a keys-based
-- lazy trigger would miss marks for files opened before the user presses
-- ; or m.
plugin.add({
  name = "arrow",
  deps = { "mini.icons" },
  src = { "https://github.com/otavioschwanck/arrow.nvim" },
  config = function()
    require("arrow").setup({
      show_icons = true,
      leader_key = ";",        -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
    })

    -- Replace arrow's signcolumn glyph (the 1/2/3… index character from
    -- `index_keys`) with a bookmark icon. The numeric index is still shown
    -- in arrow's buffer-menu UI when jumping, so we don't lose the mapping.
    -- Must run after arrow.setup so buffer_persist is loaded and its
    -- namespace exists; re-applies to any already-placed extmarks by
    -- clearing + re-rendering bookmarks in every loaded buffer.
    do
      local bp       = require("arrow.buffer_persist")
      local ns       = bp.get_ns()
      local bm_icon  = "󰃀"

      bp.redraw_bookmarks = function(bufnr, result)
        for _, res in ipairs(result) do
          local id = vim.api.nvim_buf_set_extmark(bufnr, ns, res.line - 1, -1, {
            sign_text = bm_icon,
            sign_hl_group = "ArrowBookmarkSign",
            hl_mode = "combine",
          })
          res.ext_id = id
        end
        vim.api.nvim_exec_autocmds("User", { pattern = "ArrowMarkUpdate" })
      end

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local marks = bp.get_bookmarks_by(buf)
          if marks and #marks > 0 then
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            bp.redraw_bookmarks(buf, marks)
          end
        end
      end
    end

    -- Project-wide side-car index. After arrow so the
    -- ArrowUpdate/ArrowMarkUpdate autocmds exist to hook into.
    require("neonvim.arrow_project").setup()

    utils.wk_add({
      { "<leader>a",  group = "arrow" },
      { "<leader>am", function() require("neonvim.arrow_project").pick() end, desc = "Project-wide marks", mode = "n" },
      { "<leader>aR", "<cmd>ArrowProjectRefresh<cr>",                         desc = "Refresh index",     mode = "n" },
    })
  end,
})
