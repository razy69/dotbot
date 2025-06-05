--[[
	File: blink_cmp_.lua
	Description: Completion plugin with support for LSPs and external sources that updates on every keystroke with minimal overhead (0.5-4ms async).
  Link: https://github.com/Saghen/blink.cmp
]]

local utils = require("utilities.module")
local luasnip = utils.prequire("luasnip")
local snippets_opts = {}
if luasnip then
  snippets_opts = {
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
  }

  -- Load friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()
end

require("blink.cmp").setup({
  enabled = function()
    -- Disable for some filetypes
    return not vim.tbl_contains({ "markdown", "neo-tree" }, vim.bo.filetype)
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
  end,
  fuzzy = {
    -- exact matches are always prioritized
    sorts = {
      "exact",
      "score",
      "sort_text",
    },
  },
  signature = {
    enabled = true,
    window = {
      border = "rounded",
    },
  },
  completion = {
    keyword = {
      range = "prefix",
    },
    list = {
      max_items = 50,
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
            -- (optional) use highlights from mini.icons
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
  sources = {
    default = function()
      local success, node = pcall(vim.treesitter.get_node)
      if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
        return { "buffer", "path" }
      else
        return { "lazydev", "lsp", "path", "snippets", "buffer" }
      end
    end,
    providers = {
      cmdline = {
        min_keyword_length = function(ctx)
          -- when typing a command, only show when the keyword is 3 characters or longer
          if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then return 3 end
          return 0
        end
      },
      path = {
        opts = {
          get_cwd = function(_)
            return vim.fn.getcwd()
          end,
        },
      },
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        -- make lazydev completions top priority (see `:h blink.cmp`)
        score_offset = 100,
      },
    },
  },
  snippets = snippets_opts,
  keymap = {
    ["<C-q>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },
})

