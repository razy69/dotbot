--[[
  File: lualine.lua
  Description: Neovim statusline configuration
  See: https://github.com/nvim-lualine/lualine.nvim
]]

local lualine = require("lualine")

local function get_venv()
  local py_vers =  string.sub(vim.fn.system{ "python3", "--version" }, 8, -2)
  local venv_path = os.getenv("VIRTUAL_ENV")

  if venv_path == nil then
    return string.format("system (%s)", py_vers)
  else
    local venv_name = vim.fn.fnamemodify(venv_path, ":t")
    return string.format("%s (%s)", venv_name, py_vers)
  end

end

lualine.setup({
  icons_enabled = true,
  extensions = {
    "lazy",
    "mason",
    "neo-tree",
  },
  sections = {
    lualine_a = {
      {
        "mode",
      },
    },
    lualine_b = {
      {
        "branch"
      },
      {
        "diff"
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
      },
    },
    lualine_c = {
      {
        "filename",
      },
    },
    lualine_x = {
      {"encoding"},
      {"fileformat"},
      {"filetype"},
      -- {
      --   function()
      --     return get_venv()
      --   end,
      --   cond = function() return vim.bo.filetype == "python" end,
      -- },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = false,
        path = 3,
      },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {},
})


