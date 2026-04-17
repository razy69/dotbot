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
