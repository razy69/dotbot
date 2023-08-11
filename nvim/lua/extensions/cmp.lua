--[[
  File: cmp.lua
  Description: CMP plugin configuration (with lspconfig)
  See: https://github.com/hrsh7th/nvim-cmp
]]

local cmp = require("cmp")
local lspkind = require("lspkind")


cmp.setup{

  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },

  -- Mappings for cmp
  mapping = cmp.mapping.preset.insert({

    -- Autocompletion menu
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

    -- Use <C-p> and <C-n> to navigate through completion variants
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length = 1 },  -- LSP
    { name = "nvim_lsp_signature_help" },       -- LSP for parameters in functions
    { name = "path" },                          -- Paths
    { name = "buffer", keyword_length = 4 },    -- Buffers
    { name = "nvim_lua" },                      -- Lua Neovim API
    { name = "luasnip" },                       -- Luasnip
    { name = "emoji" },                         -- Emoji
  }),

  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol", -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  }
}
