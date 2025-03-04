--[[
	File: blink_cmp_.lua
	Description: CMP plugin configuration (with lspconfig)
  See: https://github.com/Saghen/blink.cmp
]]

local utils = require("config.utils")
local luasnip = utils.prequire("luasnip")
local snippets_opts = {}
if luasnip then
  snippets_opts = {
    expand = function(snippet)
      require("luasnip").lsp_expand(snippet)
    end,
    active = function(filter)
      if filter and filter.direction then
        return require("luasnip").jumpable(filter.direction)
      end
      return require("luasnip").in_snippet()
    end,
    jump = function(direction)
      require("luasnip").jump(direction)
    end,
  }
end

require("blink.cmp").setup({
  -- Disable for some filetypes
  enabled = function()
    return not vim.tbl_contains({ "markdown", "neo-tree" }, vim.bo.filetype)
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
  end,
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  completion = {
    trigger = {
      prefetch_on_insert = true,
      show_in_snippet = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_blocked_trigger_characters = function()
        if vim.api.nvim_get_mode().mode == "c" then return {} end
        return { " ", "\n", "\t" }
      end,
      show_on_accept_on_trigger_character = true,
      show_on_insert_on_trigger_character = false,
      show_on_x_blocked_trigger_characters = { "'", '"', "(" },
    },
    list = {
      max_items = 200,
      selection = {
        preselect = false,
        auto_insert = true,
      },
    },
    documentation = {
      window = { border = "single" },
      auto_show = true,
      auto_show_delay_ms = 200,
      treesitter_highlighting = true,
    },
    menu = {
      auto_show = true,
      border = "single",
      min_width = 15,
      max_height = 10,
      scrolloff = 2,
      scrollbar = true,
      draw = {
        treesitter = { enabled = true },
        columns = {
          { "label",     "label_description", gap = 2 },
          { "kind_icon", "kind",              "source_name", gap = 1 },
        },
      },
    },
  },
  signature = {
    enabled = true,
    trigger = {
      blocked_trigger_characters = {},
      blocked_retrigger_characters = {},
      -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
      show_on_insert_on_trigger_character = true,
    },
    window = {
      border = "single",
      treesitter_highlighting = true,
    },
  },
  sources = {
    default = function(ctx)
      local success, node = pcall(vim.treesitter.get_node)
      if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
        return { "buffer", "path" }
      else
        return { "lsp", "path", "snippets", "buffer" }
      end
    end
  },
  snippets = snippets_opts,
  keymap = {
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },

    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },
})

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load()
