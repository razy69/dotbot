--[[
  File: autocmd.lua
  Description: Custom Autocmd.
]]

local utils = require("utilities.module")
local autocmd_utils = require("utilities.autocmd")

-- Check if we need to reload the file when it changed
local checktime_group = autocmd_utils.augroup("checktime")
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = checktime_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize splits if window got resized
local window_group = autocmd_utils.augroup("window")
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
-- vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
--   group = window_group,
--   callback = function(event)
--     if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].buftype == "" then
--       vim.opt_local.cursorline = true
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
--   group = autocmd_utils.augroup("auto_cursorline_hide"),
--   callback = function()
--     vim.opt_local.cursorline = false
--   end,
-- })

-- Go to last loc when opening a buffer, see ":h last-position-jump"
local buffer_group = autocmd_utils.augroup("buffer")
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

-- Disable cursor
local neotree = autocmd_utils.augroup("neotree")
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = neotree,
  callback = function()
    local filetypes = { "neo-tree" }

    if not vim.tbl_contains(filetypes, vim.bo.filetype) then
      return
    end

    vim.opt.cursorline = true
  end,
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
local filetype_group = autocmd_utils.augroup("filetype")
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Term
local term_group = autocmd_utils.augroup("term")
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  pattern = "term://*",
  callback = function(_)
    if vim.opt.buftype:get() == "terminal" then
      local set = vim.opt_local
      set.number = false         -- Don't show numbers
      set.relativenumber = false -- Don't show relativenumbers
      set.scrolloff = 0          -- Don't scroll when at the top or bottom of the terminal buffer
      vim.opt.filetype = "terminal"

      vim.cmd.startinsert() -- Start in insert mode
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = autocmd_utils.augroup("close_with_q"),
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
  group = autocmd_utils.augroup("quickfix"),
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = autocmd_utils.augroup("auto_create_dir"),
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
  group = autocmd_utils.augroup("useful"),
  callback = function()
    vim.cmd("set formatoptions-=cro")
  end,
})

-- Enable builtin syntax for specified FileType (if no treesitter support)
local syntax_group = autocmd_utils.augroup("syntax")
vim.api.nvim_create_autocmd("FileType", {
  group = syntax_group,
  pattern = { "gitsendemail", "conf", "editorconfig", "qf", "checkhealth", "less" },
  callback = function(event)
    vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
  end,
})

local theme_group = autocmd_utils.augroup("theme")
vim.api.nvim_create_autocmd("VimEnter", {
  group = theme_group,
  callback = function (_)
    if vim.env.THEME_MODE == "dark" then
      vim.o.background = "dark"
    else
      vim.o.background = "light"
    end
  end
})
