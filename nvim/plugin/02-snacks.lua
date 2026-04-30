-- Collection of small QoL plugins (dashboard, notifier, scroll, bigfile,
-- statuscolumn). Arrow.nvim integration (explorer decoration, dashboard
-- section, project-wide picker) is conditionally wired below when the
-- arrow plugin is enabled — see plugin/02-arrow.lua for the spec itself.

local arrow_enabled = plugin.is_enabled("arrow")

-- Format explorer items with an arrow mark indicator after the filename.
-- Setting item.comment hands the indicator to the built-in file
-- formatter's comment slot so it renders to the right of the filename
-- without disturbing the tree gutter alignment.
local function explorer_format(item, picker)
  if arrow_enabled and item.file and not item.dir then
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

-- Build the dashboard preset keys + sections list. The Project Marks entry
-- only appears when arrow is enabled; otherwise the dashboard would render
-- an empty section. Built outside the snacks.setup() table so a `nil`
-- entry doesn't punch a hole in the array.
local function dashboard_keys(snacks)
  local keys = {
    { icon = " ", key = "n", desc = "New File",     action = ":ene | startinsert" },
    { icon = " ", key = "f", desc = "Find File",    action = ":lua Snacks.dashboard.pick('files')" },
    { icon = " ", key = "g", desc = "Find Text",    action = ":lua Snacks.dashboard.pick('live_grep')" },
    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
    {
      icon = " ",
      key = "c",
      desc = "Config",
      action = function()
        vim.cmd("cd " .. vim.fn.stdpath("config"))
        snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
      end
    },
  }
  if arrow_enabled then
    table.insert(keys, {
      icon = "󰃀 ",
      key = "m",
      desc = "Project Marks",
      action = function() require("neonvim.arrow_project").pick() end,
    })
  end
  table.insert(keys, { icon = " ", key = "q", desc = "Quit", action = ":qa" })
  return keys
end

local function dashboard_sections()
  local sections = {
    { section = "header" },
    { icon = " ",        title = "Keymaps",      section = "keys",         indent = 2, padding = 1 },
    { icon = " ",        title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { icon = " ",        title = "Projects",     section = "projects",     indent = 2, padding = 1 },
  }
  if arrow_enabled then
    table.insert(sections, {
      icon = "󰃀 ",
      title = "Project Marks",
      section = "arrow_project_marks",
      indent = 2,
      padding = 1,
    })
  end
  return sections
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
    -- Skipped when arrow is disabled — the dashboard would render an
    -- empty section instead of nothing.
    if arrow_enabled then
      Snacks.dashboard.sections.arrow_project_marks = function(opts)
        return require("neonvim.arrow_project").dashboard_items({ limit = (opts and opts.limit) or 5 })
      end
    end

    snacks.setup({
      bigfile = { enabled = true },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        icons = {
          git = {
            added     = "",
            deleted   = "󰅙",
            modified  = "",
            renamed   = "",
            untracked = "",
            ignored   = "󰎂",
            staged    = "󰄳",
            unmerged  = "",
          },
        },
        sources = {
          explorer = {
            auto_close = true,
            replace_netrw = true,
            format = explorer_format,
            -- Use the documented `sidebar` preset, but override position to
            -- nil + col/row to 0. snacks' default `position = "left"` flips
            -- the layout into "split-style" handling (extra wincmd navigation
            -- + tabline/cmdheight offsets + main-window preview path), which
            -- briefly paints a duplicate of the main buffer at the right
            -- during toggle. Anchoring as a pure left-edge float skips all
            -- that machinery while looking identical to the user.
            layout = {
              preset = "sidebar",
              ---@diagnostic disable-next-line: assign-type-mismatch
              preview = false,
              layout = {
                position = "float",
                col = 0,
                row = 0,
                border = "rounded",
              },
            },
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
          keys = dashboard_keys(snacks),
        },
        sections = dashboard_sections(),
      },
      image = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        top_down = true,
      },
      terminal = { enabled = true },
      statuscolumn = {
        enabled = true,
        -- Left: diagnostics + (extmark) signs, including arrow's bookmark sign.
        -- Right: git diff takes priority over folds — snacks only shows one
        -- sign per side per line, and iterating this list picks the first
        -- matching type. With fold first, a folded line hid the diff marker.
        left = { "mark", "sign" },
        right = { "git", "fold" },
        folds = {
          open = true, -- show the ▾/▸ icon on open folds, not just closed ones
          git_hl = false,
        },
        refresh = 50,
      },
    })

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
