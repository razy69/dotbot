--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]


local lspkind = require("lspkind")
local cmp = require("cmp")
local luasnip = require("luasnip")


lspkind.init{
  mode = "symbol_text",
  preset = "codicons",
}

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({

	enabled = function()
		if require("cmp.config.context").in_treesitter_capture("comment") == true
			or require("cmp.config.context").in_syntax_group("Comment") then
			return false
		else
			return true
		end
	end,

	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
	    luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},

	-- Mappings for cmp
	mapping = cmp.mapping.preset.insert({

		-- Autocompletion menu
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        fallback()
      elseif cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      else
        fallback()
      end
    end, { "i", "s" }),

		-- Use <C-p> and <C-n> to navigate through completion variants
		["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
       	cmp.complete()
      else
        fallback()
      end
		end, { "i", "s" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
       	cmp.complete()
      else
        fallback()
      end
		end, { "i", "s" }),

    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
      	cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
      	cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
	}),

	autocomplete = false,

	sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "treesitter", keyword_length = 3, max_item_count = 3 },
    { name = "path" },
    { name = "buffer", keyword_length = 3, max_item_count = 3 },
    { name = "luasnip", keyword_length = 3, max_item_count = 3 },
    { name = "pandoc_references" },
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
