--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

require("globals")


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


-- Go to last loc when opening a buffer
api.nvim_create_autocmd({"BufReadPost"}, {
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
api.nvim_create_autocmd({"BufWritePre"}, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    fn.mkdir(fn.fnamemodify(file, ":p:h"), "p")
  end,
})


-- Alpha vim Disable folding on alpha buffer
api.nvim_create_autocmd({"FileType"}, {
  pattern = "alpha",
  callback = function()
    opt.foldenable = false
		vim.cmd("highlight clear EoLSpace")
  end
})

-- Alpha vim Hide tabline
api.nvim_create_autocmd({"User"}, {
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

-- Alpha vim Show tabline
api.nvim_create_autocmd({"BufUnload"}, {
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

-- Color override highlights
vim.cmd("match EoLSpace /\\s\\+$/")

api.nvim_create_autocmd({"InsertLeave"}, {
  desc = "Enable EoLSpace highlight and match rule",
  callback = function()
    if (vim.bo.filetype ~= "neo-tree") then
      vim.cmd("highlight EoLSpace ctermbg=238 guibg=#cb214e")
    end
  end,
})

api.nvim_create_autocmd({"InsertEnter"}, {
  desc = "Disable EoLSpace highlight and match rule",
  callback = function()
    vim.cmd("highlight clear EoLSpace")
  end,
})
