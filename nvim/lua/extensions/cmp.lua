--[[
  File: cmp.lua
  Description: CMP plugin configuration (with lspconfig)
  See: https://github.com/hrsh7th/nvim-cmp
]]

local cmp = require("cmp")
local lspkind = require("lspkind")


cmp.setup({

  enabled = function()
    local lnum, col = vim.fn.line("."), math.min(vim.fn.col("."), #vim.fn.getline("."))
    for _, syn_id in ipairs(vim.fn.synstack(lnum, col)) do
      syn_id = vim.fn.synIDtrans(syn_id) -- Resolve :highlight links
      if vim.fn.synIDattr(syn_id, "name") == "Comment" then
        return false
        end
    end
    return true
  end,

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
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end,
      s = cmp.mapping.confirm({ select = true }),
      c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    }),

    -- Use <C-p> and <C-n> to navigate through completion variants
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length = 2 },  							-- LSP
    { name = "nvim_lsp_signature_help", keyword_length = 2 }, -- LSP for parameters in functions
    { name = "buffer", keyword_length = 2 },     							-- Buffers
    { name = "path", keyword_length = 3},	                    -- Paths
    { name = "nvim_lua" },                      							-- Lua Neovim API
    { name = "luasnip" },                       							-- Luasnip
    { name = "emoji" },                         							-- Emoji
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
  },

})
