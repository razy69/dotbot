--[[
  File: lualine_.lua
  Description: Blazing fast and easy to configure Neovim statusline written in Lua.
  Link: https://github.com/nvim-lualine/lualine.nvim
]]

local utils = require("utilities.module")
local trouble = utils.prequire("trouble")
if trouble then
  vim.g.trouble_lualine = true -- Show the current document symbols location from Trouble in lualine
end

require("lualine").setup({
  theme = "catppuccin",
  icons_enabled = true,
  globalstatus = false,
  extensions = {
    "fzf",
    "lazy",
    "mason",
    "neo-tree",
    "nvim-dap-ui",
    "quickfix",
    "trouble",
  },
  refresh = {
    statusline = 100,
  },
  sections = {
    lualine_a = {
      {
        "mode",
      },
    },
    lualine_b = {
      {
        "branch",
        on_click = function()
          local fzf = utils.prequire("fzf-lua")
          if not fzf then
            return
          end
          fzf.git_branches()
        end
      },
      {
        "diff",
        on_click = function()
          local fzf = utils.prequire("fzf-lua")
          if not fzf then
            return
          end
          fzf.git_status()
        end
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
        colored = true,
        update_in_insert = false,
        always_visible = false,
        on_click = function()
          if not trouble then
            return
          end
          vim.api.nvim_command("Trouble diagnostics")
        end
      },
      {
        function()
          local arrow_status = utils.prequire("arrow.statusline")
          return arrow_status and arrow_status.text_for_statusline_with_icons() or ""
        end
      },
    },
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 3,
        symbols = {
          modified = "[~]",      -- Text to show when the file is modified.
          readonly = "[-]",      -- Text to show when the file is non-modifiable or readonly.
          unnamed = "[No Name]", -- Text to show for unnamed buffers.
          newfile = "[+]",
        },
      },
    },
    lualine_x = {
      { "encoding" },
      { "fileformat" },
      {
        function()
          local mini_icons = require("mini.icons")
          local filetype = vim.bo.filetype
          local icon = mini_icons.get(
            "filetype",
            vim.api.nvim_get_option_value("filetype", { buf = 0 })
          ) .. " " or ""
          local text = icon .. filetype
          return string.format("%s", text)
        end,
        on_click = function()
          local fzf = utils.prequire("fzf-lua")
          if not fzf then
            return
          end
          fzf.filetypes()
        end,
      },
      {
        "lsp_status",
        icon = "", -- f013
        symbols = {
          -- Standard unicode symbols to cycle through for LSP progress:
          spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          -- Standard unicode symbol for when LSP is done:
          done = "✓",
          -- Delimiter inserted between LSP names:
          separator = " ",
        },
        -- List of LSP names to ignore (e.g., `null-ls`):
        ignore_lsp = {},
        on_click = function()
          vim.api.nvim_command("LspInfo")
        end
      },
    },
    lualine_y = {
      { "selectioncount" },
      { "progress" },
    },
    lualine_z = {
      { "location" },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 3,
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
})
