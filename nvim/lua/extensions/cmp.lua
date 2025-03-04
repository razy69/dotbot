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

local is_not_comment = function()
  local context = require("cmp.config.context")
  return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
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

local is_not_luasnip = function()
  ---@diagnostic disable-next-line: param-type-mismatch
  return not fn.expand("%:p"):find(".*/nvim/lua/snippets/.*%.lua")
end

local cmp_is_enabled = function()
  return is_not_comment() and is_not_buftype() and is_not_filetype() and is_not_luasnip()
end

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end


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

  enabled = function()
    return cmp_is_enabled()
  end,

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
    end, { "i", "s" }),
    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    -- ["<Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   elseif has_words_before() then
    --     cmp.complete()
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { "i", "s" }),
  },

  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
      group_index = 1,
    },
    {
      name = "nvim_lsp_signature_help",
      group_index = 1,
    },
    {
      name = "treesitter",
      keyword_length = 3,
      group_index = 2,
    },
    {
      name = "nvim_lua",
      group_index = 2,
    },
    -- {
    --   name = "luasnip",
    --   keyword_length = 3,
    --   max_item_count = 1,
    --   option = { use_show_condition = true },
    --   entry_filter = function()
    --     local context = require("cmp.config.context")
    --     return not context.in_treesitter_capture("string") and not context.in_syntax_group("String")
    --   end,
    -- },
    -- {
    --   name = "buffer",
    --   keyword_length = 3,
    --   max_item_count = 5,
    --   group_index = 4,
    --   option = {
    --     get_bufnrs = function()
    --       local bufs = {}
    --       for _, win in ipairs(vim.api.nvim_list_wins()) do
    --         bufs[vim.api.nvim_win_get_buf(win)] = true
    --       end
    --       return vim.tbl_keys(bufs)
    --     end,
    --   },
    -- },
    {
      name = "path",
      keyword_length = 4,
      max_item_count = 3,
      group_index = 4,
    },
    -- {
    --   name = "emoji",
    --   group_index = 5,
    -- },
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

-- require("luasnip.loaders.from_vscode").lazy_load()
