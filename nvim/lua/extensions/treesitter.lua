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
  auto_install = true,
  highlight = {
    -- Enabling highlight for all files
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}
