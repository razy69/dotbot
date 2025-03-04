--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]


local lspkind = require("lspkind")
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp_select_opts = {behavior = cmp.SelectBehavior.Select}
local luasnip = require("luasnip")


lspkind.init{
  mode = "symbol_text",
  preset = "codicons",
}

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

  preselect = "item",
  completion = {
    completeopt = "menu,menuone,noinsert",
  },

	-- Mappings for cmp
	mapping = {

		-- Autocompletion menu
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({select = false}),
    ["<C-p>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item(cmp_select_opts)
      else
        cmp.complete()
      end
    end),
    ["<C-n>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item(cmp_select_opts)
      else
        cmp.complete()
      end
    end),
	},

	autocomplete = false,

	sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "treesitter", keyword_length = 3},
    { name = "path" },
    { name = "buffer", keyword_length = 3, max_item_count = 3 },
    { name = "luasnip", keyword_length = 3, max_item_count = 3 },
    { name = "spell" },
    { name = "calc" },
    { name = "emoji" },
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
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
		})
	},

})

require("luasnip.loaders.from_vscode").lazy_load()
