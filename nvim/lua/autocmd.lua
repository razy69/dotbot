--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

require("globals")

local notify = require("notify")
local notify_title = "RazyVim AutoCmd"

-- Copied from LazyVim
local function augroup(name)
  return api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ timeout = 50 })
  end,
})

-- Resize splits if window got resized
api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    notify("Resize Window", "info", { title = notify_title })
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer, see ":h last-position-jump"
api.nvim_create_autocmd({"BufWinEnter", "FileType"}, {
  group = augroup("last_loc"),
  callback = function()
    local ignore_buftype = { "quickfix", "nofile", "help" }
    local ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }

    if vim.tbl_contains(ignore_buftype, vim.bo.buftype) then
      return
    end

    if vim.tbl_contains(ignore_filetype, vim.bo.filetype) then
      -- reset cursor to first line
      vim.cmd[[normal! gg]]
      return
    end

    -- If a line has already been specified on the command line, we are done
    --   nvim file +num
    if vim.fn.line(".") > 1 then
      return
    end

    local last_line = vim.fn.line([['"]])
    local buff_last_line = vim.fn.line("$")

    -- If the last line is set and the less than the last line in the buffer
    if last_line > 0 and last_line <= buff_last_line then
      local win_last_line = vim.fn.line("w$")
      local win_first_line = vim.fn.line("w0")
      -- Check if the last line of the buffer is the same as the win
      if win_last_line == buff_last_line then
        -- Set line to last line edited
        vim.cmd[[normal! g`"]]
        -- Try to center
      elseif buff_last_line - last_line > ((win_last_line - win_first_line) / 2) - 1 then
        vim.cmd[[normal! g`"zz]]
      else
        vim.cmd[[normal! G'"<c-e>]]
      end
    end
  end
})

-- Show cursor line only in active window
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  group = augroup("auto_cursorline_show"),
  callback = function(event)
    if vim.bo[event.buf].buftype == "" then
      vim.opt_local.cursorline = true
    end
  end,
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  group = augroup("auto_cursorline_hide"),
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Wrap and check for spell in text filetypes
api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Python setup tabs
api.nvim_create_autocmd("FileType", {
  desc = "Configure Nvim for Python",
  group = augroup("python"),
  pattern = { "*.py" },
  callback = function()
    notify("Applying Python Settings..", "info", { title = notify_title })
    opt.tabstop = 4
    opt.softtabstop = 4
    opt.shiftwidth = 4
    opt.expandtab = true
    opt.autoindent = true
    opt.fileformat = "unix"
  end
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_autocmd("BufWritePre", {
  desc = "Create missing dir when saving file",
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    fn.mkdir(fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Alpha vim Disable folding on alpha buffer
api.nvim_create_autocmd("FileType", {
  desc = "Disable folding for alpha",
  group = augroup("alpha"),
  pattern = "alpha",
  callback = function()
    opt.foldenable = false
    vim.cmd("highlight clear EoLSpace")
  end
})

-- Alpha Enter
api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  desc = "Disable tabline for alpha",
  callback = function()
    local hl = api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 100
    api.nvim_set_hl(0, "Cursor", hl)
    opt.guicursor:append("a:Cursor/lCursor")
    require("lualine").hide()
    require("illuminate").invisible_buf()
  end,
})

-- Alpha Exit
api.nvim_create_autocmd("BufUnload", {
  desc = "Enable tabline after alpha",
  callback = function()
    local hl = api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 0
    api.nvim_set_hl(0, "Cursor", hl)
    require("lualine").hide({ unhide = true })
  end,
})

api.nvim_create_autocmd("TabNewEntered", {
  desc = "Open Alpha on new tab",
  group = augroup("alpha"),
  callback = function()
    require("alpha").start()
  end,
})

-- Color override highlights
api.nvim_create_autocmd("InsertEnter", {
  desc = "Disable EoLSpace highlight and match rule",
  group = augroup("highlight"),
  callback = function()
    vim.cmd("highlight clear EoLSpace")
  end,
})

api.nvim_create_autocmd("InsertLeave", {
  desc = "Enable EoLSpace highlight and match rule",
  group = augroup("highlight"),
  callback = function()
    if (vim.bo.filetype ~= "neo-tree") then
      vim.cmd("highlight EoLSpace ctermbg=238 guibg=#cb214e")
    end
  end,
})

-- Barbecue/Navic
api.nvim_create_autocmd({
  "WinResized",
  "BufWinEnter",
  "CursorHold",
  "InsertLeave",
}, {
  group = api.nvim_create_augroup("barbecue.updater", {}),
  callback = function()
    require("barbecue.ui").update()
  end,
})

-- Disable some features for big files.
api.nvim_create_autocmd("FileType", {
  group = augroup("bigfile"),
  pattern = "bigfile",
  callback = function(ev)
    notify("bigfile detected, applying minimal mode..", "warning", { title = notify_title })
    opt.cursorline = false
    opt.cursorcolumn = false
    opt.list = false
    opt.wrap = false
    vim.b.minianimate_disable = true
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})
