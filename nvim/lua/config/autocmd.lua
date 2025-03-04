--[[
  File: autocmd.lua
  Description: Setup autocmd
]]

local notify = require("notify")
local notify_title = "RazyVim AutoCmd"

-- Copied from LazyVim
local function augroup(name)
  return vim.api.nvim_create_augroup("razyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
local checktime_group = augroup("checktime")
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = checktime_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
local highlight_group = augroup("highlight")
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank({ timeout = 50 })
  end,
})

-- Color override highlights
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
local window_group = augroup("window")
vim.api.nvim_create_autocmd("VimResized", {
  group = window_group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
    require("fzf-lua").redraw()
  end,
})

-- Show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  group = window_group,
  callback = function(event)
    if vim.bo[event.buf].buftype == "" then
      vim.opt_local.cursorline = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  group = augroup("auto_cursorline_hide"),
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Go to last loc when opening a buffer, see ":h last-position-jump"
local buffer_group = augroup("buffer")
vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
  group = buffer_group,
  callback = function()
    local ignore_buftype = { "quickfix", "nofile", "help" }
    local ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }

    if vim.tbl_contains(ignore_buftype, vim.bo.buftype) then
      return
    end

    if vim.tbl_contains(ignore_filetype, vim.bo.filetype) then
      -- reset cursor to first line
      vim.cmd [[normal! gg]]
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
        vim.cmd [[normal! g`"]]
        -- Try to center
      elseif buff_last_line - last_line > ((win_last_line - win_first_line) / 2) - 1 then
        vim.cmd [[normal! g`"zz]]
      else
        vim.cmd [[normal! G'"<c-e>]]
      end
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
local filetype_group = augroup("filetype")
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
    notify("Applying Python Settings..", "info", { title = notify_title })
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.autoindent = true
    vim.opt.fileformat = "unix"
  end
})

-- Disable some features for big files.
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = "bigfile",
  callback = function(ev)
    notify("bigfile detected, applying minimal mode..", "warning", { title = notify_title })

    vim.opt.syntax = "off"
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
    vim.opt.list = false
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.foldmethod = "manual"
    vim.opt.undolevels = -1
    vim.opt.undoreload = 0
    vim.b.minianimate_disable = true

    vim.cmd("syntax clear")
    vim.cmd("LspStop")
    vim.cmd("IlluminatePause")
    vim.cmd("NoMatchParen")
    vim.cmd("IBLDisable")
    vim.cmd("Barbecue disable")

    local _, ts_config = pcall(require, "nvim-treesitter.configs")
    for _, mod_name in ipairs(ts_config.available_modules()) do
      vim.cmd("TSDisable " .. mod_name)
    end

    require("lualine").hide()

    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})

-- Alpha Enter
local alpha_group = augroup("alpha")
vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
  desc = "Alpha Enter",
  group = alpha_group,
  callback = function()
    if (vim.bo.filetype ~= "alpha") then
      return
    end

    vim.cmd("highlight clear EoLSpace")

    -- Cursor hide
    local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 100
    vim.api.nvim_set_hl(0, "Cursor", hl)
    vim.opt.guicursor:append("a:Cursor/lCursor")

    require("lualine").hide()
    require("illuminate").invisible_buf()
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  desc = "Alpha Enter",
  group = alpha_group,
  callback = function()
    if (vim.bo.filetype ~= "alpha") then
      return
    end

    -- Cursor show
    local hl = vim.api.nvim_get_hl_by_name("Cursor", true)
    hl.blend = 0
    vim.api.nvim_set_hl(0, "Cursor", hl)
    vim.opt.guicursor:remove("a:Cursor/lCursor")

    vim.opt.foldenable = false
    require("lualine").hide({ unhide = true })
  end,
})

vim.api.nvim_create_autocmd("TabNewEntered", {
  desc = "Open Alpha on new tab",
  group = alpha_group,
  callback = function()
    require("alpha").start()
  end,
})

-- Barbecue/Navic
local barbecue_group = augroup("barbecue")
vim.api.nvim_create_autocmd({
  "WinResized",
  "BufWinEnter",
  "CursorHold",
  "InsertLeave",
}, {
  desc = "Update Barbecue",
  group = barbecue_group,
  callback = function()
    require("barbecue.ui").update()
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "grug-far",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "dbout",
    "gitsigns-blame",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Add keybindings for lspconfig
local fzf = require("fzf-lua")

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("UserLspConfig"),
  callback = function(ev)
    -- Jumps to the declaration of the symbol under the cursor.
    vim.keymap.set(
      "n",
      "gD",
      function()
        fzf.lsp_declarations({
          sync = true,
          jump_to_single_result = true,
          jump_to_single_result_action = require("fzf-lua.actions").file_vsplit,
        })
      end,
      {
        desc = "LSP Go to declaration",
        buffer = ev.buf,
      }
    )

    -- Jumps to the definition of the symbol under the cursor.
    vim.keymap.set(
      "n",
      "gd",
      function()
        fzf.lsp_definitions({
          sync = true,
          ignore_current_line = true,
          jump_to_single_result = true,
          jump_to_single_result_action = require("fzf-lua.actions").file_vsplit,
        })
      end,
      {
        desc = "LSP Go to definition",
        buffer = ev.buf,
      }
    )

    -- Lists all the references to the symbol under the cursor in the quickfix window.
    vim.keymap.set(
      "n",
      "gr",
      function()
        fzf.lsp_references({
          ignore_current_line = true,
          includeDeclaration = false, -- Combined with ignore_current_line = true, it achieves "show other usages" behavior.
        })
      end,
      {
        desc = "LSP References",
        buffer = ev.buf,
      }
    )

    -- Lists all the implementations for the symbol under the cursor in the quickfix window.
    vim.keymap.set(
      "n",
      "gi",
      function()
        fzf.lsp_implementations({
          ignore_current_line = true,
          jump_to_single_result = true,
        })
      end,
      {
        desc = "LSP Implementations",
        buffer = ev.buf,
      }
    )

    -- Selects a code action available at the current cursor position.
    vim.keymap.set(
      { "n", "v" },
      "<leader>ca",
      function()
        fzf.lsp_code_actions()
      end,
      {
        desc = "LSP Code action",
        buffer = ev.buf,
      }
    )

    -- Live workspace symbols query
    vim.keymap.set(
      { "n", "v" },
      "<leader>ls",
      function()
        fzf.lsp_live_workspace_symbols()
      end,
      {
        desc = "LSP Live Symbols",
        buffer = ev.buf,
      }
    )

    -- Displays hover information about the symbol under the cursor in a floating
    -- window. Calling the function twice will jump into the floating window.
    vim.keymap.set(
      "n",
      "K",
      vim.lsp.buf.hover,
      {
        desc = "LSP Hover",
        buffer = ev.buf,
      }
    )

    -- Displays signature information about the symbol under the cursor in a floating window.
    vim.keymap.set(
      "n",
      "<C-k>",
      vim.lsp.buf.signature_help,
      {
        desc = "LSP Signature help",
        buffer = ev.buf,
      }
    )

    -- Renames all references to the symbol under the cursor.
    vim.keymap.set(
      "n",
      "<leader>rn",
      vim.lsp.buf.rename,
      {
        desc = "LSP Rename references",
        buffer = ev.buf,
      }
    )
  end
})
