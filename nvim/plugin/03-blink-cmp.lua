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
    "https://github.com/saghen/blink.lib",
    "https://github.com/xzbdmw/colorful-menu.nvim",
    { src = "https://github.com/saghen/blink.cmp" },
  },
  build = function(info)
    if info.name == "LuaSnip" then
      vim.cmd("make install_jsregexp")
    elseif info.name == "blink.cmp" then
      -- cmp.build() runs cargo, moves the artifact from target/release/ to
      -- v2's lib/ cache, and loads it in-process. This DOES block, for up to
      -- 60s — deliberately: it only runs from a PackChanged install/update
      -- (never at startup), and waiting there means the rust fuzzy lib is
      -- ready when :PackUpdate returns rather than silently falling back to
      -- the slower lua implementation for the rest of the session.
      require("blink.cmp").build():pwait(60000)
    end
  end,
  config = function()
    -- Load friendly snippets off the critical path: this config runs on the
    -- first InsertEnter/CmdlineEnter, and the loader scans the snippets
    -- directory tree, so doing it inline added that cost to the first keystroke.
    vim.schedule(function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end)

    local blink = require("blink.cmp")

    -- Runtime safety net for in-place v1->v2 upgrades: the build hook
    -- only fires on PackChanged (install/update), so an already-installed
    -- blink.cmp keeps its v1-era target/release/ artifact and v2 looks
    -- under lib/. library_available() checks the v2 cache; if it's
    -- missing we kick off the build async (same task as the build hook).
    if not blink.library_available() then
      blink.build()
    end

    blink.setup({
      enabled = function()
        -- Disable for some filetypes
        return not vim.tbl_contains({ "markdown" }, vim.bo.filetype)
            and vim.bo.buftype ~= "prompt"
            and vim.b.completion ~= false
      end,
      fuzzy = {
        implementation = "prefer_rust_with_warning",
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
              label = {
                width = { fill = true, max = 60 },
                text = function(ctx)
                  local highlights_info = require("colorful-menu").blink_highlights(ctx)
                  if highlights_info ~= nil then
                    -- Or you want to add more item to label
                    return highlights_info.label
                  else
                    return ctx.label
                  end
                end,
                highlight = function(ctx)
                  local highlights = {}
                  local highlights_info = require("colorful-menu").blink_highlights(ctx)
                  if highlights_info ~= nil then
                    highlights = highlights_info.highlights
                  end
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end
                  -- Do something else
                  return highlights
                end,
              },
            }
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
          return require("luasnip").jump(direction)
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
