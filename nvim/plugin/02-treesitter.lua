-- Treesitter: syntax highlighting, folding, and indentation
plugin.add({
  name = "treesitter",
  src = {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
  },
  build = function(info)
    if info.name == "nvim-treesitter" and info.kind == "update" then
      require("nvim-treesitter").update()
    end
  end,
  config = function()
    -- Configure treesitter
    require("nvim-treesitter").setup({
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      endwise = { enable = true },
      autotag = { enable = true },
      matchup = { enable = true },
      folds = { enable = true },
    })

    -- Parsers to guarantee are installed; missing ones are installed on startup.
    local ensure_installed = {
      "bash",
      "c",
      "cpp",
      "css",
      "dockerfile",
      "git_config",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gotmpl",
      "gpg",
      "hcl",
      "helm",
      "html",
      "http",
      "ini",
      "java",
      "javascript",
      "jq",
      "json",
      "lua",
      "make",
      "markdown",
      "mermaid",
      "nginx",
      "perl",
      "php",
      "powershell",
      "puppet",
      "python",
      "regex",
      "ruby",
      "rust",
      "scss",
      "svelte",
      "sql",
      "ssh_config",
      "terraform",
      "tmux",
      "toml",
      "tsx",
      "typescript",
      "vimdoc",
      "vue",
      "xml",
      "yaml",
      "zsh"
    }

    -- Install only parsers not already present in the runtime (deferred to avoid blocking startup)
    local to_install = vim.tbl_filter(function(lang)
      return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
    end, ensure_installed)
    if #to_install > 0 then
      vim.schedule(function()
        require("nvim-treesitter").install(to_install)
      end)
    end

    -- Configure treesitter-context
    require("treesitter-context").setup({})

    -- Configure nvim-ts-context-commentstring
    require("ts_context_commentstring").setup({})

    -- On FileType, enable treesitter highlighting and kick hlargs on the ready parser.
    -- Uses "*" pattern — vim.treesitter.start() no-ops gracefully for unsupported filetypes.
    -- Folding is handled globally via options.lua foldexpr (treesitter) and overridden
    -- to LSP foldexpr in 03-lsp.lua when the server supports it.
    --
    -- We intentionally do NOT install `require'nvim-treesitter'.indent()` as the
    -- indentexpr. That function returns 0 for empty / near-empty lines that sit
    -- between open and close brackets, which breaks blink.pairs' <CR><C-o>O split
    -- (plugin/01-blink-pairs.lua) and also strips indent off plain <CR>s inside
    -- balanced pairs. Vim's built-in ftplugin indentexprs (GetLuaIndent,
    -- GetJavascriptIndent, GetPythonIndent, …) handle these cases correctly.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(ev)
        local buf = ev.buf
        local ft = vim.bo[buf].ft
        if ft == "" then return end

        local ok = pcall(vim.treesitter.start, buf)
        if not ok then return end

        -- Force hlargs to (re)initialise now that the treesitter parser exists.
        -- Guards against the race where hlargs' BufEnter fires before the parser
        -- is available and caches `ignore = true` for the buffer; the FileType
        -- retry inside hlargs only fires when the filetype *changes*, so without
        -- this call a fresh buffer may never get arg highlights.
        local hl_ok, hlargs = pcall(require, "hlargs")
        if hl_ok and type(hlargs.enable_buf) == "function" then
          pcall(hlargs.enable_buf, buf)
        end
      end,
    })
  end,
})
