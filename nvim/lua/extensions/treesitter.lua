--[[
  File: treesitter.lua
  Description: Configuration of tree-sitter
  See: https://github.com/tree-sitter/tree-sitter
]]

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = -1
opt.foldenable = false
opt.foldlevel = 99

require("nvim-treesitter.configs").setup{

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
    "markdown_inline",
    "perl",
    "puppet",
    "python",
    "regex",
    "ruby",
    "rst",
    "sql",
    "terraform",
    "toml",
    "vim",
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

vim.diagnostic.config({
  virtual_text = {
    -- source = "always",  -- Or "if_many"
    prefix = "▎", -- Could be '■', '▎', 'x'
  },
  severity_sort = true,
  float = {
    source = "always",  -- Or "if_many"
  },
})
