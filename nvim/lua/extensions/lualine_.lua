--[[
  File: lualine.lua
  Description: Neovim statusline configuration
  See: https://github.com/nvim-lualine/lualine.nvim
]]

local lualine = require("lualine")

lualine.setup({
  theme = "catppuccin",
  icons_enabled = true,
  globalstatus = false,
  extensions = {
    "lazy",
    "mason",
    "neo-tree",
    "trouble",
  },
  refresh = {
    statusline = 500,
    tabline = 1000,
    winbar = 1000,
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
          vim.api.nvim_command("Telescope git_branches")
        end
      },
      {
        "diff",
        on_click = function()
          vim.api.nvim_command("DiffviewOpen")
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
          vim.api.nvim_command("Trouble diagnostics")
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
        on_click = function()
          vim.api.nvim_command("Neotree toggle")
        end
      },
    },
    lualine_x = {
      { "encoding" },
      { "fileformat" },
      {
        function()
          local lsps = vim.lsp.get_active_clients({ bufnr = vim.fn.bufnr() })
          local filetype = vim.bo.filetype
          local icon = require("nvim-web-devicons").get_icon_by_filetype(
            vim.api.nvim_buf_get_option(0, "filetype")
          ) .. " " or ""
          local text = icon .. filetype

          if lsps and #lsps > 0 then
            local lsp_names = {}
            for _, lsp in ipairs(lsps) do
              table.insert(lsp_names, lsp.name)
            end
            local names = table.concat(lsp_names, ", ")
            if #names > 20 then
              names = string.sub(names, 0, 18)
              names = names .. ".."
            end
            return string.format("%s (LSP: %s)", text, names)
          else
            return text
          end
        end,
        on_click = function()
          vim.api.nvim_command("LspInfo")
        end,
        color = function()
          local _, color = require("nvim-web-devicons").get_icon_cterm_color_by_filetype(
            vim.api.nvim_buf_get_option(0, "filetype")
          )
          return { fg = color }
        end,
      },
    },
    lualine_y = {
      { "selectioncount" },
      { "progress" },
    },
    lualine_z = {
      { "location" }
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
