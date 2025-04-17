--[[
	File: blink_cmp_.lua
	Description: Completion plugin with support for LSPs and external sources that updates on every keystroke with minimal overhead (0.5-4ms async).
  Link: https://github.com/Saghen/blink.cmp
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

  -- Load friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()
end

require("blink.cmp").setup({
  enabled = function()
    -- Disable for some filetypes
    return not vim.tbl_contains({ "markdown", "neo-tree" }, vim.bo.filetype)
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
  end,
  signature = {
    enabled = true,
    window = {
      border = "rounded",
    },
  },
  completion = {
    keyword = {
      range = "prefix",
    },
    list = {
      max_items = 50,
      selection = {
        preselect = function(_)
          return not require("blink.cmp").snippet_active({ direction = 1 })
        end,
        auto_insert = false,
      },
    },
    documentation = {
      window = { border = "rounded" },
      auto_show = true,
      auto_show_delay_ms = 200,
      treesitter_highlighting = true,
    },
    menu = {
      border = "rounded",
      draw = {
        columns = {
          { "label",     "label_description", gap = 2 },
          { "kind_icon", "kind",              "source_name", gap = 1 },
        },
      },
    },
  },
  cmdline = {
    completion = {
      ghost_text = { enabled = false },
      menu = { auto_show = true },
    },
  },
  sources = {
    default = function(_)
      local success, node = pcall(vim.treesitter.get_node)
      if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
        return { "buffer", "path" }
      else
        return { "lsp", "path", "snippets", "buffer" }
      end
    end,
  },
  snippets = snippets_opts,
  keymap = {
    ["<C-q>"] = { "hide", "fallback" },
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
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },

    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },
})
