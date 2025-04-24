--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

local M = {}
local utils = require("config.utils")

-- Helper to ceate augroup (from LazyVim)
function M.augroup(name)
  return vim.api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
local checktime_group = M.augroup("checktime")
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = checktime_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
local highlight_group = M.augroup("highlight")
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ timeout = 50 })
  end,
})

-- Colorize EOL space
vim.api.nvim_create_autocmd("InsertEnter", {
  desc = "Disable EoLSpace highlight and match rule",
  group = highlight_group,
  callback = function()
    vim.cmd("highlight clear EoLSpace")
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Enable EoLSpace highlight and match rule",
  group = highlight_group,
  callback = function()
    if (vim.bo.filetype == "neo-tree") then
      return
    end
    vim.cmd("highlight EoLSpace ctermbg=238 guibg=#cb214e")
  end,
})

-- Resize splits if window got resized
local window_group = M.augroup("window")
vim.api.nvim_create_autocmd("VimResized", {
  group = window_group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)

    local fzf_lua = utils.prequire("fzf-lua")
    if fzf_lua then
      fzf_lua.redraw()
    end
  end,
})

-- Show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  group = window_group,
  callback = function(event)
    if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].buftype == "" then
      vim.opt_local.cursorline = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  group = M.augroup("auto_cursorline_hide"),
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Go to last loc when opening a buffer, see ":h last-position-jump"
local buffer_group = M.augroup("buffer")
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = buffer_group,
  pattern = { "*" },
  callback = function()
    local ignore_buftype = { "quickfix", "nofile", "help" }
    local ft = vim.opt_local.filetype:get()

    -- don't apply on specific file type
    if vim.tbl_contains(ignore_buftype, ft) then
      return
    end
    -- don't apply to git messages
    if (ft:match("commit") or ft:match("rebase")) then
      return
    end
    -- get position of last saved edit
    local markpos = vim.api.nvim_buf_get_mark(0, '"')
    local line = markpos[1]
    local col = markpos[2]
    -- if in range, go there
    if (line > 1) and (line <= vim.api.nvim_buf_line_count(0)) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Create missing dir when saving file",
  group = buffer_group,
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Wrap and check for spell in text filetypes
local filetype_group = M.augroup("filetype")
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Python setup tabs
vim.api.nvim_create_autocmd("FileType", {
  desc = "Configure Nvim for Python",
  group = filetype_group,
  pattern = { "*.py" },
  callback = function()
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.autoindent = true
    vim.opt.fileformat = "unix"
  end
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = M.augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "startuptime",
    "checkhealth",
    "gitsigns-blame",
    "man",
  },
  callback = function(event)
    if not vim.api.nvim_buf_is_valid(event.buf) then return end
    vim.bo[event.buf].buflisted = false
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

-- Unlist quickfix buffers
vim.api.nvim_create_autocmd("FileType", {
  group = M.augroup("quickfix"),
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = M.augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Don't auto comment new line
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = M.augroup("useful"),
  callback = function()
    vim.cmd("set formatoptions-=cro")
  end,
})

-- Toggles the search highlight automatically
local hl_search_group = M.augroup("hl_search")
vim.api.nvim_create_autocmd("InsertEnter", {
  group = hl_search_group,
  callback = function()
    vim.schedule(function() vim.cmd("nohlsearch") end)
  end
})

vim.api.nvim_create_autocmd("CursorMoved", {
  group = hl_search_group,
  callback = function()
    -- No bloat lua adpatation of: https://github.com/romainl/vim-cool
    local view, rpos = vim.fn.winsaveview(), vim.fn.getpos(".")
    -- Move the cursor to a position where (whereas in active search) pressing `n`
    -- brings us to the original cursor position, in a forward search / that means
    -- one column before the match, in a backward search ? we move one col forward
    vim.cmd(string.format("silent! keepjumps go%s",
      (vim.fn.line2byte(view.lnum) + view.col + 1 - (vim.v.searchforward == 1 and 2 or 0))))
    -- Attempt to goto next match, if we're in an active search cursor position
    -- should be equal to original cursor position
    local ok, _ = pcall(vim.cmd, "silent! keepjumps norm! n")
    local insearch = ok and (function()
      local npos = vim.fn.getpos(".")
      return npos[2] == rpos[2] and npos[3] == rpos[3]
    end)()
    -- restore original view and position
    vim.fn.winrestview(view)
    if not insearch then
      vim.schedule(function() vim.cmd("nohlsearch") end)
    end
  end
})

-- Enable builtin syntax for specified FileType (if no treesitter support)
local syntax_group = M.augroup("syntax")
vim.api.nvim_create_autocmd("FileType", {
  group = syntax_group,
  pattern = { "gitsendemail", "conf", "editorconfig", "qf", "checkhealth", "less" },
  callback = function(event)
    vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
  end,
})

-- Disable LSP Inlay Hints in Insert mode
local lsp_inlay_hints_group = M.augroup("lsp_inlay_hints")
vim.api.nvim_create_autocmd("InsertEnter", {
  group = lsp_inlay_hints_group,
  pattern = "*",
  callback = function(event)
    vim.schedule(function()
      vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
    end)
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = lsp_inlay_hints_group,
  pattern = "*",
  callback = function(event)
    vim.schedule(function()
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end)
  end,
})

return M
