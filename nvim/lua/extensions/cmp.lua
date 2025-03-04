--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]

require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

lspkind.init({
  mode = "symbol_text",
  preset = "codicons",
})

cmp.setup({

  formatting = {
    format = lspkind.cmp_format({
      maxwidth = 50,
      ellipsis_char = "...",
      mode = "symbol_text",
      menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        treesitter = "[TreeSitter]",
        async_path = "[Path]",
        git = "[Git]",
        nvim_lua = "[Lua]",
      })
    }),
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  preselect = cmp.SelectBehavior.Select,
  completion = { completeopt = "menu,menuone,noselect" },

  -- Mappings for cmp
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-f>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-b>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      local col = vim.fn.col(".") - 1
      if cmp.visible() then
        cmp.select_next_item()
      elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
        fallback()
      else
        cmp.complete()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },

  sources = {
    {
      name = "luasnip",
      group_index = 1,
      option = { show_autosnippets = true, use_show_condition = false },
    },
    {
      name = "nvim_lua",
      group_index = 1,
      entry_filter = function()
        if vim.bo.filetype ~= "lua" then
          return false
        end
        return true
      end,
    },
    {
      name = "nvim_lsp",
      group_index = 2,
    },
    {
      name = "nvim_lsp_signature_help",
      group_index = 2,
    },
    {
      name = "treesitter",
      group_index = 3,
      max_item_count = 3,
      entry_filter = function(entry, vim_item)
        if entry.kind == 15 then
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local line = vim.api.nvim_get_current_line()
          local next_char = line:sub(cursor_pos[2] + 1, cursor_pos[2] + 1)
          if next_char == '"' or next_char == "'" then
            vim_item.abbr = vim_item.abbr:sub(1, -2)
          end
        end
        return vim_item
      end,
    },
    {
      name = "buffer",
      group_index = 4,
      max_item_count = 5,
      keyword_length = 2,
      entry_filter = function(entry)
        return not entry.exact
      end,
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    {
      name = "git",
      group_index = 5,
      entry_filter = function()
        if vim.bo.filetype ~= "gitcommit" then
          return false
        end
        return true
      end,
    },
    {
      name = "async_path",
      group_index = 5,
    },
  },

  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      require("cmp-under-comparator").under,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  matching = {
    disallow_fuzzy_matching = true,
    disallow_fullfuzzy_matching = true,
    disallow_partial_fuzzy_matching = true,
    disallow_partial_matching = false,
    disallow_prefix_unmatching = true,
    disallow_symbol_nonprefix_matching = true,
  },

  performance = {
    debounce = 0,
    throttle = 0,
  },
})

-- Set configuration for specific filetype
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({ { name = "git" } }, { { name = "buffer" } })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    {
      { name = "nvim_lsp_document_symbol" }
    },
    {
      { name = "buffer" }
    }
  ),
})

-- Use cmdline & path source for ":" (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
    {
      { name = "async_path" }
    },
    {
      { name = "cmdline" }
    }
  )
})
