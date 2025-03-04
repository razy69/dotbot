--[[
  File: lualine.lua
  Description: Neovim statusline configuration
  See: https://github.com/nvim-lualine/lualine.nvim
]]

local lualine = require("lualine")

local function get_venv(variable)
  local py_vers =  string.sub(vim.fn.system{ "python3", "--version" }, 8, -2)
  local venv = os.getenv(variable)
  if venv ~= nil and string.find(venv, "/") then
    local orig_venv = venv
    for w in orig_venv:gmatch("([^/]+)") do
      venv = w
    end
    venv = string.format("%s (%s)", venv, py_vers)
  end
  return venv
end

lualine.setup({
  icons_enabled = true,
  extensions = {
    "lazy",
    "neo-tree",
  },
  sections = {
    lualine_a = {
      {
        "mode"
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
        file_status = true,
        newfile_status = false,
        path = 3,
      },
    },
    lualine_x = {
      {"encoding"},
      {"fileformat"},
      {"filetype"},
      {
        function()
          local venv = get_venv("CONDA_DEFAULT_ENV") or get_venv("VIRTUAL_ENV") or "NO ENV"
            return venv
          end,
        cond = function() return vim.bo.filetype == "python" end,
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {},
})


