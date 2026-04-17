-- Statusline with catppuccin theme
plugin.add({
  name = "lualine",
  src = "https://github.com/nvim-lualine/lualine.nvim",
  -- Defer until after init.lua finishes; the statusline doesn't need to exist
  -- before the first frame. Saves init-path time without visible delay.
  event = { "VimEnter" },
  config = function()
    -- Configure lualine (fzf-lua required lazily inside callbacks to avoid
    -- pulling it in at startup — enables fzf-lua lazy-loading via cmd/keys)
    require("lualine").setup({
      theme = "catppuccin",
      icons_enabled = true,
      globalstatus = false,
      extensions = {
        "fzf",
        "mason",
        "neo-tree",
        "quickfix",
      },
      refresh = {
        statusline = 300,
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
              require("fzf-lua").git_branches()
            end
          },
          {
            "diff",
            on_click = function()
              require("fzf-lua").git_status()
            end
          },
          {
            "diagnostics",
            sources = { "nvim_lsp" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            colored = true,
            update_in_insert = false,
            always_visible = false,
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
              local icon = mini_icons.get("filetype", filetype) .. " " or ""
              local text = icon .. filetype
              return string.format("%s", text)
            end,
            on_click = function()
              require("fzf-lua").filetypes()
            end,
          },
          {
            "lsp_status",
            icon = "", -- f013
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
              vim.cmd("LspInfo")
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
  end,
})
