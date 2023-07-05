--[[
  File: treesitter.lua
  Description: Configuration of tree-sitter
  See: https://github.com/tree-sitter/tree-sitter
]]

require("nvim-treesitter.configs").setup {

  -- Needed parsers
  ensure_installed = {
    "bash",
    "c",
    "cmake",
    "comment",
    "cpp",
    "css",
    "dockerfile",
    "git_config",
    "gitattributes",
    "gitignore",
    "lua",
    "go",
    "gomod",
    "gosum",
    "javascript",
    "jsonc",
    "hcl",
    "html",
    "ini",
    "make",
    "markdown",
    "perl",
    "python",
    "ruby",
    "rst",
    "sql",
    "terraform",
    "toml",
    "yaml",
  },

  -- Install all parsers synchronously
  sync_install = false,

  -- Подсветка
  highlight = {
    -- Enabling highlight for all files
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = true,
  },

  indent = {
    -- Disabling indentation for all files
    enable = true,
    disable = {"yaml"},
  },

  rainbow = {
    enable = true,
    -- list of languages you want to disable the plugin for
    -- disable = { "jsx", "cpp" },
    -- Which query to use for finding delimiters
    query = "rainbow-parens",
    -- Do not enable for files with more than n lines
    max_file_lines = 3000
  }
}

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = -1
opt.foldenable = false
opt.foldlevel = 99