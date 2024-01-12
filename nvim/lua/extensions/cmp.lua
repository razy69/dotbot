--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]


local lspkind = require("lspkind")
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp_action = require("lsp-zero").cmp_action()
local luasnip = require("luasnip")

lspkind.init({
  mode = "symbol_text",
  preset = "codicons",
})

-- Add parentheses after selecting function or method item
cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done()
)

cmp.setup({

  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },

  preselect = cmp.PreselectMode.Item,
  keyword_length = 2,
  completion = {
    completeopt = "menu,menuone,noinsert",
  },

  -- Mappings for cmp
  mapping = {
    ["<C-f>"] = cmp_action.luasnip_jump_forward(),
    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      select = false,
      behavior = cmp.ConfirmBehavior.Replace,
    }),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),

  },

  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
      group_index = 1,
      keyword_length = 2,
    },
    {
      name = "nvim_lsp_signature_help",
      group_index = 1,
      keyword_length = 2,
    },
    {
      name = "treesitter",
      keyword_length = 3,
      group_index = 2,
    },
    {
      name = "nvim_lua",
      keyword_length = 3,
      group_index = 2,
    },
    {
      name = "path",
      keyword_length = 4,
      max_item_count = 3,
      group_index = 3,
    },
  }),

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

  formatting = {
    format = lspkind.cmp_format({
      maxwidth = 50,
      ellipsis_char = "...",
    })
  },

})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won"t work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" }
  }
})

-- Use cmdline & path source for ":" (if you enabled `native_menu`, this won"t work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
      { name = "path" }
    },
    {
      { name = "cmdline" }
    })
})

require("luasnip.loaders.from_vscode").lazy_load()
