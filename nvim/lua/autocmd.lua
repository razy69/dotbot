--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

require "helpers/globals"


-- Copied from LazyVim
local function augroup(name)
  return api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end


-- Python setup tabs
api.nvim_create_autocmd("FileType", {
  pattern = { "*.py" },
  callback = function()
    opt.tabstop = 4
    opt.softtabstop = 4
    opt.shiftwidth = 4
    opt.expandtab = true
    opt.autoindent = true
    opt.fileformat = "unix"
  end
})


-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})


-- Go to last loc when opening a buffer
api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = api.nvim_buf_get_mark(buf, '"')
    local lcount = api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


-- Auto create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    fn.mkdir(fn.fnamemodify(file, ":p:h"), "p")
  end,
})


-- Lint on Leave Insert Mode
api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    require("lint").try_lint()
  end
})
