--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

require "helpers/globals"


-- User [[[

-- Copied from LazyVim
local function augroup(name)
  return api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

-- Python autocmd to setup tab
api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function ()
    opt.tabstop = 4
    opt.softtabstop = 4
    opt.shiftwidth = 4
  end
})

-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = fn.tabpagenr()
    cmd("tabdo wincmd =")
    cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
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

-- wrap and check for spell in text filetypes
api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
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
-- ]]]


-- alpha.vim [[[

-- Disable folding on alpha buffer
api.nvim_create_autocmd("FileType", {
  pattern = "alpha",
  callback = function ()
    opt.foldenable = false
  end
})

-- Hide/Show tabline
api.nvim_create_autocmd("User", {
	pattern = "AlphaReady",
	desc = "disable tabline for alpha",
	callback = function()
		opt.showtabline = 0
		local hl = api.nvim_get_hl_by_name("Cursor", true)
		hl.blend = 100
		api.nvim_set_hl(0, "Cursor", hl)
	  opt.guicursor:append("a:Cursor/lCursor")
		require("illuminate").invisible_buf()
	end,
})

api.nvim_create_autocmd("BufUnload", {
	buffer = 0,
	desc = "enable tabline after alpha",
	callback = function()
		opt.showtabline = 2
		local hl = api.nvim_get_hl_by_name("Cursor", true)
		hl.blend = 0
		api.nvim_set_hl(0, "Cursor", hl)
		opt.guicursor:remove("a:Cursor/lCursor")
	end,
})

-- ]]]


-- lint.nvim [[[

-- Lint on Leave Insert Mode
api.nvim_create_autocmd("BufWritePost" , {
  callback = function()
    require("lint").try_lint()
  end
})

-- ]]]
