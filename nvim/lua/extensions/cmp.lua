--[[
	File: cmp.lua
	Description: CMP plugin configuration (with lspconfig)
	See: https://github.com/hrsh7th/nvim-cmp
]]


local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local is_not_filetype = function()
	local ft = vim.bo.filetype
	local exclude_ft = {
		"neorepl",
		"neoai-input",
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
  enabled = function ()
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
      winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
    },
    documentation = cmp.config.window.bordered {
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
    },
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  preselect = cmp.SelectBehavior.Select,
  completion = { completeopt = "menu,menuone,noinsert" },

  -- Mappings for cmp
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<C-e>"] = cmp.mapping.abort(),
		["<C-n>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s", "c" }),
    ["<C-p>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s", "c" }),
  },

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    {
      name = "treesitter",
      max_item_count = 3,
    },
    {
      name = "luasnip",
      max_item_count = 1,
    },
    {
      name = "nvim_lua",
      max_item_count = 1,
    },
    {
      name = "async_path",
      max_item_count = 1,
    },
		{
      name = "buffer",
      max_item_count = 1,
      keyword_length = 500,
      priority = 1,
    },
  }),

  cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({{ name = "git" }}, {{ name = "buffer" }})
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
})


-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" }
  }, {
    { name = "buffer" }
  }),
})

-- Use cmdline & path source for ":" (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
      { name = "async_path" }
    },
    {
      { name = "cmdline" }
    })
})
