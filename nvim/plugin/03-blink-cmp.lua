-- Completion engine with Rust fuzzy matcher.
-- blink_pairs is a dep so it loads before this plugin's config runs: that
-- way blink.cmp's `<CR>` fallback captures blink.pairs' CR-split handler
-- instead of the default newline, so pressing <CR> between `({[` pairs
-- produces an indented split (see plugin/02-blink-pairs.lua).
plugin.add({
  name = "blink_cmp",
  deps = { "blink_pairs" },
  event = { "InsertEnter", "CmdlineEnter" },
  src = {
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/rafamadriz/friendly-snippets",
    -- Pin to v1.x: main branch has moved to an unreleased v2 rewrite with
    -- breaking config-API changes. Latest released tag as of writing is
    -- v1.10.2. vim.version.range("1") resolves to the highest v1.* tag.
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
  },
  build = function(info)
    if info.name == "LuaSnip" then
      vim.cmd("make install_jsregexp")
    elseif info.name == "blink.cmp" then
      local ext = jit.os == "OSX" and "dylib" or (jit.os == "Windows" and "dll" or "so")
      local lib = vim.fs.joinpath(info.path, "target", "release", "libblink_cmp_fuzzy." .. ext)
      if info.kind == "install" or not vim.uv.fs_stat(lib) then
        vim.system({ "cargo", "build", "--release" }, { cwd = info.path }):wait()
      else
        vim.system({ "cargo", "build", "--release" }, { cwd = info.path }, function(r)
          local lvl = r.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          vim.notify("blink.cmp: fuzzy build " .. (r.code == 0 and "ok" or "failed"), lvl)
        end)
      end
    end
  end,
  config = function()
    -- Build the Rust fuzzy library in background if missing (first install or wiped data dir).
    -- Completion works immediately via Lua fallback; native speed after restart.
    local blink_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt", "blink.cmp")
    local ext = jit.os == "OSX" and "dylib" or (jit.os == "Windows" and "dll" or "so")
    local blink_lib = vim.fs.joinpath(blink_dir, "target", "release", "libblink_cmp_fuzzy." .. ext)
    local rust_ready = vim.uv.fs_stat(blink_lib) ~= nil
    if vim.uv.fs_stat(blink_dir) and not rust_ready then
      vim.notify("blink.cmp: building fuzzy library in background (first install)...", vim.log.levels.INFO)
      vim.system({ "cargo", "build", "--release" }, { cwd = blink_dir }, function(result)
        local lvl = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        local msg = result.code == 0
            and "blink.cmp: fuzzy library built (restart for native speed)"
            or "blink.cmp: fuzzy library build failed\n" .. (result.stderr or "")
        vim.schedule(function()
          vim.notify(msg, lvl)
        end)
      end)
    end

    -- Load friendly snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Configure blink.cmp
    require("blink.cmp").setup({
      enabled = function()
        -- Disable for some filetypes
        return not vim.tbl_contains({ "markdown", "neo-tree" }, vim.bo.filetype)
            and vim.bo.buftype ~= "prompt"
            and vim.b.completion ~= false
      end,
      fuzzy = {
        -- Pin to Lua when the rust binary isn't on disk yet. blink.cmp's
        -- download path will set_implementation("rust") mid-session, but the
        -- worker threads spawned by buffer-source parsing and fuzzy.access
        -- can't `require('blink.cmp.fuzzy.rust')` cleanly (the module's
        -- init.lua rewrites package.cpath via debug.getinfo, which fails
        -- inside uv.new_work's fresh Lua state) — surfacing as stray
        -- "Luv thread:\n[NULL]" lines. After restart the .so is present
        -- and native speed kicks in without the race.
        implementation = rust_ready and "prefer_rust_with_warning" or "lua",
        -- exact matches are always prioritized
        sorts = {
          "exact",
          "score",
          "sort_text",
          "label",
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        keyword = {
          range = "prefix",
        },
        list = {
          max_items = 100,
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        documentation = {
          window = { border = "rounded" },
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
        },
        menu = {
          auto_show = true,
          border = "rounded",
          draw = {
            columns = {
              { "label",     "label_description", gap = 2 },
              { "kind_icon", "kind",              "source_name", gap = 1 },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        trigger = {
          show_in_snippet = true,
        },
      },
      cmdline = {
        completion = {
          menu = {
            -- show the menu only when writing commands
            auto_show = function(_)
              return vim.fn.getcmdtype() == ":" or vim.fn.getcmdtype() == "@"
            end,
          },
          ghost_text = {
            enabled = function()
              return vim.fn.getcmdtype() == ":"
            end,
          },
        },
        keymap = {
          ["<Tab>"] = { "show", "accept" },
          ["<C-q>"] = { "hide", "accept" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },

        },
      },
      snippets = {
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
        score_offset = -1,
      },
      sources = {
        -- Dynamically select sources: inside comments only offer buffer+path
        -- (no LSP/snippets noise), otherwise use the full source list.
        -- Lua buffers get `lazydev` prepended — it loads Neovim + plugin
        -- types on-demand; the plugin itself is ft-gated in plugin/02-lazydev.lua.
        default = function()
          local success, node = pcall(vim.treesitter.get_node)
          if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
            return { "buffer", "path" }
          elseif vim.bo.filetype == "lua" then
            return { "lazydev", "lsp", "path", "snippets", "buffer" }
          else
            return { "lsp", "path", "snippets", "buffer" }
          end
        end,
        providers = {
          lsp = {
            fallbacks = {},
            score_offset = 0,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- Rank lazydev ahead of lsp so require("xxx") suggestions surface first.
            score_offset = 100,
          },
          cmdline = {
            min_keyword_length = function(ctx)
              -- when typing a command, only show when the keyword is 2 characters or longer
              if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then return 2 end
              return 0
            end,
            score_offset = -1,
          },
          path = {
            opts = {
              get_cwd = function(_)
                return vim.fn.getcwd()
              end,
            },
            score_offset = -2,
          },
        },
      },
      keymap = {
        -- <Tab>: accept in menu → jump snippet placeholder → literal tab.
        -- We gate snippet jumping on luasnip.jumpable(direction) instead of
        -- blink's "snippet_forward" because the latter routes through
        -- snippets.active(), which calls luasnip.in_snippet() and stays true
        -- even after the cursor has moved past the last tabstop (a "stuck"
        -- snippet session). jumpable(n) is strict — false when there's no
        -- next placeholder — so <Tab> falls through to a literal tab.
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_visible() then
              if cmp.snippet_active() then
                return cmp.accept()
              else
                return cmp.select_and_accept()
              end
            end
            local ok, ls = pcall(require, "luasnip")
            if ok and ls.jumpable(1) then
              ls.jump(1)
              return true
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          function(_)
            local ok, ls = pcall(require, "luasnip")
            if ok and ls.jumpable(-1) then
              ls.jump(-1)
              return true
            end
          end,
          "fallback",
        },
        ["<C-q>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-space>"] = { "show" },
      },
    })
  end,
})
