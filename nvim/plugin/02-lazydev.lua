-- lazydev.nvim: auto-loads Neovim runtime + plugin types into lua-language-server
-- on demand (only when you `require("foo")`). ft-gated so it never loads for
-- non-Lua buffers. Blink.cmp references its integration module by string, so no
-- ordering constraint with blink.cmp — the require happens lazily when blink
-- queries completions on a Lua buffer.
plugin.add({
  name = "lazydev",
  src = "https://github.com/folke/lazydev.nvim",
  ft = { "lua" },
  config = function()
    -- Walk pack/core/opt and register each installed plugin as a lazydev
    -- library entry, keyed on its top-level lua/ module names. When a Lua
    -- buffer requires a module that lives in one of these plugins, lazydev
    -- adds that plugin's source to lua_ls so hover / goto-def / completion
    -- work — without preloading every plugin's source at startup.
    local library = {
      -- Neovim runtime types (vim.api, vim.fn, vim.lsp, …). Resolved from
      -- vim.env.VIMRUNTIME so it works regardless of whether $VIMRUNTIME
      -- is exported in the shell that launched lua-language-server.
      vim.env.VIMRUNTIME,
      -- Async I/O types for vim.uv (lives outside pack/, so add explicitly).
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    }

    -- Escape Lua-pattern metacharacters so module names like `nvim-lint`,
    -- `mini.icons`, or `blink.cmp` match literally in buffer content.
    local function pattern_escape(s)
      return (s:gsub("[%%%-%.%+%*%?%[%]%^%$%(%)]", "%%%1"))
    end

    -- Skip module names that are too generic — they'd match anywhere in any
    -- Lua buffer and pull in unrelated plugin sources. Plugins with only
    -- generic top-level modules (rare) get no auto-discovery; require them
    -- explicitly via a manual library entry if the types matter.
    local generic = {
      init = true,
      util = true,
      utils = true,
      helpers = true,
      config = true,
      common = true,
      types = true,
      internal = true,
    }

    local opt_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
    if vim.fn.isdirectory(opt_dir) == 1 then
      for _, plugin_dir in ipairs(vim.fn.readdir(opt_dir)) do
        local lua_dir = vim.fs.joinpath(opt_dir, plugin_dir, "lua")
        if vim.fn.isdirectory(lua_dir) == 1 then
          local words = {}
          local seen = {}
          for _, entry in ipairs(vim.fn.readdir(lua_dir)) do
            local mod
            if entry:match("%.lua$") and entry ~= "init.lua" then
              mod = entry:gsub("%.lua$", "")
            elseif vim.fn.isdirectory(vim.fs.joinpath(lua_dir, entry)) == 1 then
              mod = entry
            end
            if mod and mod ~= "" and not seen[mod] and not generic[mod:lower()] then
              seen[mod] = true
              table.insert(words, pattern_escape(mod))
            end
          end
          if #words > 0 then
            table.insert(library, {
              path = vim.fs.joinpath(opt_dir, plugin_dir),
              words = words,
            })
          end
        end
      end
    end

    require("lazydev").setup({ library = library })
  end,
})
