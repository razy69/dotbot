--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]


local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local is_not_filetype = function()
  local ft = vim.bo.filetype
  local exclude_ft = {
    "neorepl",
  }
  for _, v in pairs(exclude_ft) do
    if ft == v then
      return false
    end
  end
  return true
end

local is_not_buftype = function()
  local bt = vim.bo.buftype
  local exclude_bt = {
    "prompt",
    "nofile",
  }
  for _, v in pairs(exclude_bt) do
    if bt == v then
      return false
    end
  end
  return true
end

require("luasnip.loaders.from_vscode").lazy_load()

lspkind.init({
  mode = "symbol_text",
  preset = "codicons",
})

cmp.setup({

  -- Disabling completion in certain contexts
  enabled = function()
    return is_not_buftype() and is_not_filetype()
  end,

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
    completion = cmp.config.window.bordered {
      -- border = "single",
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
    documentation = cmp.config.window.bordered {
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
    },
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  preselect = cmp.SelectBehavior.Select,
  completion = { completeopt = "menu,menuone,preview,noselect" },

  -- Mappings for cmp
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if #cmp.get_entries() == 1 then
          cmp.confirm({ select = true })
        else
          cmp.select_next_item()
        end
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
        if #cmp.get_entries() == 1 then
          cmp.confirm({ select = true })
        end
      else
        fallback()
      end
    end, { "i", "s", "c" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s", "c" }),
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
