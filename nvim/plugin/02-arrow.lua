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
      local bp            = require("arrow.buffer_persist")
      local ns            = bp.get_ns()
      local bm_icon       = "󰃀"

      ---@diagnostic disable-next-line: duplicate-set-field
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
      { "<leader>aR", "<cmd>ArrowProjectRefresh<cr>",                         desc = "Refresh index",      mode = "n" },
    })
  end,
})
