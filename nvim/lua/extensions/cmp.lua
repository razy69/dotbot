--[[
  File: cmp.lua
  Description: CMP plugin configuration (with lspconfig)
  See: https://github.com/hrsh7th/nvim-cmp
]]

local cmp = require("cmp")
local lspkind = require("lspkind")


cmp.setup{

  -- Mappings for cmp
  mapping = {

    -- Autocompletion menu
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i" }),
    ["<CR>"] = cmp.config.disable,                      -- Turn off autocomplete on <CR>
    ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Turn on autocomplete on <C-y>

    -- Use <C-e> to abort autocomplete
    ["<C-e>"] = cmp.mapping({
      i = cmp.mapping.abort(), -- Abort completion
      c = cmp.mapping.close(), -- Close completion window
    }),

    -- Use <C-p> and <C-n> to navigate through completion variants
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
  },

  sources = cmp.config.sources({
    { name = "nvim_lsp" },                -- LSP
    { name = "nvim_lsp_signature_help" }, -- LSP for parameters in functions
    { name = "nvim_lua" },                -- Lua Neovim API
    { name = "luasnip" },                 -- Luasnip
    { name = "buffer" },                  -- Buffers
    { name = "path" },                    -- Paths
    { name = "emoji" },                   -- Emoji
  }),

  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol", -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  }
}

require("cmp_nvim_lsp").default_capabilities()
