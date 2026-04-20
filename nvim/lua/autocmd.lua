---@brief Global autocommands for the neonvim configuration.

-- Reload files changed outside of Neovim (e.g. by git, external editors)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = utils.augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Restore cursor to last known position when opening a buffer (see :h last-position-jump)
local buffer_group = utils.augroup("buffer")
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = buffer_group,
  pattern = { "*" },
  callback = function()
    local ignore_filetypes = { "quickfix", "help" }
    local ignore_buftypes = { "nofile" }
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype

    -- Skip special buffer/file types
    if vim.tbl_contains(ignore_filetypes, ft) or vim.tbl_contains(ignore_buftypes, bt) then
      return
    end
    -- Skip git commit/rebase buffers (always start at top)
    if ft:match("commit") or ft:match("rebase") then
      return
    end
    -- Jump to the last saved cursor position
    local markpos = vim.api.nvim_buf_get_mark(0, '"')
    local line = markpos[1]
    local col = markpos[2]
    if (line > 1) and (line <= vim.api.nvim_buf_line_count(0)) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end
})

-- Enable word wrap and spell checking for text-oriented filetypes
local filetype_group = utils.augroup("filetype")
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Force spaces over tabs for every filetype (runtime ftplugins like go.vim set noexpandtab).
-- Makefiles are excluded because recipe lines structurally require a leading tab.
vim.api.nvim_create_autocmd("FileType", {
  group = utils.augroup("force_expandtab"),
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "make" or vim.bo.filetype == "automake" then
      return
    end
    vim.opt_local.expandtab = true
  end,
})

-- Configure terminal buffers: hide line numbers, auto-enter insert mode
local term_group = utils.augroup("term")
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  pattern = "term://*",
  callback = function(_)
    if vim.opt.buftype:get() == "terminal" then
      local set = vim.opt_local
      set.number = false
      set.relativenumber = false
      set.scrolloff = 0
      vim.opt.filetype = "terminal"
      vim.cmd.startinsert()
    end
  end,
})

-- Map <q> to close certain read-only/utility filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = utils.augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "gitsigns-blame",
    "help",
    "lspinfo",
    "man",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "query",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    -- Deferred to ensure the buffer's filetype keymaps are set first
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        nowait = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Hide quickfix buffers from the buffer list
vim.api.nvim_create_autocmd("FileType", {
  group = utils.augroup("quickfix"),
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

-- Auto-create parent directories when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = utils.augroup("auto_create_dir"),
  callback = function(event)
    -- Skip remote/protocol URIs (e.g. scp://, fugitive://)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Guard against ftplugins re-adding c/r/o to formatoptions (auto-insert comment leader)
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = utils.augroup("useful"),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Re-enable builtin syntax highlighting for filetypes without treesitter support
local syntax_group = utils.augroup("syntax")
vim.api.nvim_create_autocmd("FileType", {
  group = syntax_group,
  pattern = { "gitsendemail", "conf", "editorconfig", "qf", "checkhealth", "less" },
  callback = function(event)
    vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
  end,
})

-- Enrich :substitute live-preview split ('inccommand=split'). The preview
-- is drawn into a `[Preview]` buffer, but the window attached to it is
-- transient and can be absent from nvim_list_wins/tabpage_list_wins during
-- cmdpreview. We therefore use a decoration provider: its `on_win`
-- callback fires per-window-redraw and sees the preview window even when
-- the Lua enumeration APIs don't. Inside on_win we:
--   1. copy the source buffer's filetype onto the preview buffer (starts
--      treesitter via the FileType autocmd in 02-treesitter.lua)
--   2. conceal the per-line `|<lnum>|` prefix added by Neovim
--   3. override the window's statuscolumn to show the real source lnum
local preview_ns = vim.api.nvim_create_namespace("inccommand_preview")
local preview_source_ft = nil

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = utils.augroup("inccommand_preview_cmdline"),
  pattern = ":",
  callback = function()
    local ft = vim.bo.filetype
    preview_source_ft = ft ~= "" and ft or nil
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = utils.augroup("inccommand_preview_cmdline_leave"),
  callback = function() preview_source_ft = nil end,
})

-- Neovim prefixes each preview line with the source lnum, right-padded so
-- all line numbers in a batch share the same column width (e.g. `| 4|`,
-- `|44|`). Return (source_lnum, prefix_byte_len) on match.
local function parse_preview_prefix(line)
  local n, rest = line:match("^|%s*(%d+)%s*|%s?()")
  if n then return tonumber(n), rest - 1 end
  return nil
end

vim.api.nvim_set_decoration_provider(preview_ns, {
  on_win = function(_, winid, bufnr, _, _)
    if not preview_source_ft then return false end
    if not vim.api.nvim_buf_is_valid(bufnr) then return false end
    local name = vim.api.nvim_buf_get_name(bufnr)
    if not name:match("%[Preview%]$") then return false end

    -- Setting 'filetype' and starting treesitter aren't allowed inside a
    -- decoration-provider fast callback — defer to vim.schedule. Guard
    -- against re-scheduling for every redraw by checking current state.
    if vim.bo[bufnr].filetype ~= preview_source_ft then
      local b, ft = bufnr, preview_source_ft
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(b) then return end
        if vim.bo[b].filetype ~= ft then
          pcall(function() vim.bo[b].filetype = ft end)
        end
        local lang = vim.treesitter.language.get_lang(ft)
        if lang then pcall(vim.treesitter.start, b, lang) end
      end)
    end

    -- Rebuild lnum map + extmarks each redraw (fast-safe APIs).
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local line_map = {}
    local line_count = 0
    vim.api.nvim_buf_clear_namespace(bufnr, preview_ns, 0, -1)
    for i, line in ipairs(lines) do
      local src_lnum, prefix_len = parse_preview_prefix(line)
      if src_lnum and prefix_len and prefix_len > 0 then
        line_map[tostring(i)] = src_lnum
        line_count = line_count + 1
        pcall(vim.api.nvim_buf_set_extmark, bufnr, preview_ns, i - 1, 0, {
          end_col = prefix_len,
          conceal = "",
        })
      end
    end

    -- Count actual match occurrences (one line may contain several).
    -- Neovim draws its own Substitute-highlighted extmarks on the matches;
    -- counting those is cheaper than re-parsing the pattern.
    local match_count = 0
    local ok_marks, all_marks = pcall(
      vim.api.nvim_buf_get_extmarks, bufnr, -1, 0, -1, { details = true }
    )
    if ok_marks and type(all_marks) == "table" then
      for _, m in ipairs(all_marks) do
        local d = m[4]
        if d and (d.hl_group == "Substitute" or d.hl_group == "IncSearch") then
          match_count = match_count + 1
        end
      end
    end
    if match_count == 0 then match_count = line_count end

    -- Overlay the change count at the right edge of the first preview
    -- line via an extmark. virt_text_pos="right_align" doesn't consume
    -- layout space, so the statusline and window height stay intact
    -- (setting 'winbar' was stealing a row and hiding the statusline).
    if #lines > 0 then
      local summary = (" %d change%s on %d line%s "):format(
        match_count, match_count == 1 and "" or "s",
        line_count, line_count == 1 and "" or "s")
      pcall(vim.api.nvim_buf_set_extmark, bufnr, preview_ns, 0, 0, {
        virt_text = { { summary, "Comment" } },
        virt_text_pos = "right_align",
        hl_mode = "combine",
      })
    end

    -- Window-local vars/options are fast-safe in practice (confirmed by
    -- statuscolumn and conceal both applying from here).
    if vim.api.nvim_win_is_valid(winid) then
      pcall(function() vim.w[winid].inccommand_line_map = line_map end)
      pcall(function()
        vim.wo[winid].statuscolumn = "%=%{get(w:inccommand_line_map,string(v:lnum),'')} "
        vim.wo[winid].conceallevel = 3
        vim.wo[winid].concealcursor = "nvic"
        vim.wo[winid].number = false
        vim.wo[winid].relativenumber = false
        vim.wo[winid].signcolumn = "no"
        vim.wo[winid].foldcolumn = "0"
      end)
    end
  end,
})

-- Set background from THEME_MODE env var on startup (integrates with system dark/light mode)
local theme_group = utils.augroup("theme")
vim.api.nvim_create_autocmd("VimEnter", {
  group = theme_group,
  callback = function(_)
    local mode = vim.env.THEME_MODE
    if mode == "dark" or mode == "light" then
      vim.o.background = mode
    else
      vim.o.background = "light"
    end
  end
})
