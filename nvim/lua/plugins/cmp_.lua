--[[
	File: nvim-cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

lspkind.init({
  mode = "symbol_text",
  preset = "codicons",
})

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  enabled = function ()
    -- disable completion in comments
    local context = require("cmp.config.context")
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    else
      return not context.in_treesitter_capture("comment")
        and not context.in_syntax_group("Comment")
    end
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
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  preselect = cmp.SelectBehavior.None,
  completion = { completeopt = "menu,menuone,noinsert,noselect" },
  -- Mappings for cmp
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.snippet.active({ direction = 1 }) then
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.snippet.active({ direction = -1 }) then
        vim.schedule(function()
          vim.snippet.jump(-1)
        end)
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

-- nvim-autopairs
cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done()
)
