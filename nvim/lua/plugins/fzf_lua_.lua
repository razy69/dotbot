--[[
  File: fzf_lua_.lua
  Description: Fuzzy finder.
  Link: https://github.com/ibhagwan/fzf-lua
]]

local fzf_lua = require("fzf-lua")
local fzf_lua_actions = require("fzf-lua.actions")
local autocmd = require("config.autocmd")
local utils = require("config.utils")
local hlargs = utils.prequire("hlargs")

fzf_lua.setup({
  "fzf-native",
  winopts = {
    preview = { default = "bat" },
    split = "belowright new" -- open in split right of current window
  },
  fzf_opts = { ["--cycle"] = true },
  grep = {
    resume         = true,                                         -- resume last search
    rg_opts        = "--sort-files --hidden --column --line-number --no-heading " ..
        "--color=always --smart-case -g '!{.git,node_modules}/*'", -- sort results (to be always in the same order, may impact perf)
    rg_glob        = true,                                         -- enable glob parsing by default to all
    glob_flag      = "--iglob",                                    -- for case sensitive globs use '--glob'
    glob_separator = "%s%-%-"                                      -- query separator pattern (lua): ' --'
  },
})

fzf_lua.register_ui_select(function(_, items)
  local min_h, max_h = 0.15, 0.70
  local h = (#items + 4) / vim.o.lines
  if h < min_h then
    h = min_h
  elseif h > max_h then
    h = max_h
  end
  return { winopts = { height = h, width = 0.60, row = 0.40 } }
end)

-- Add keybindings for lspconfig
vim.api.nvim_create_autocmd("LspAttach", {
  group = autocmd.augroup("UserLspConfig"),
  callback = function(ev)
    -- Jumps to the declaration of the symbol under the cursor.
    vim.keymap.set(
      "n",
      "gD",
      function()
        fzf_lua.lsp_declarations({
          sync = true,
          jump1 = true,
          jump1_action = fzf_lua_actions.file_vsplit,
        })
      end,
      {
        desc = "LSP Go to declaration",
        buffer = ev.buf,
      }
    )
    vim.keymap.set(
      "n",
      "gvD",
      function()
        fzf_lua.lsp_declarations({
          sync = true,
          jump1 = true,
          jump1_action = fzf_lua_actions.file_split,
        })
      end,
      {
        desc = "LSP Go to declaration",
        buffer = ev.buf,
      }
    )

    -- Jumps to the definition of the symbol under the cursor.
    vim.keymap.set(
      "n",
      "gd",
      function()
        fzf_lua.lsp_definitions({
          sync = true,
          ignore_current_line = true,
          jump1 = true,
          jump1_action = fzf_lua_actions.file_vsplit,
        })
      end,
      {
        desc = "LSP Go to definition (vsplit)",
        buffer = ev.buf,
      }
    )
    vim.keymap.set(
      "n",
      "gvd",
      function()
        fzf_lua.lsp_definitions({
          sync = true,
          ignore_current_line = true,
          jump1 = true,
          jump1_action = fzf_lua_actions.file_split,
        })
      end,
      {
        desc = "LSP Go to definition (split)",
        buffer = ev.buf,
      }
    )

    -- Lists all the references to the symbol under the cursor in the quickfix window.
    vim.keymap.set(
      "n",
      "gr",
      function()
        fzf_lua.lsp_references({
          ignore_current_line = true,
          includeDeclaration = false, -- Combined with ignore_current_line = true, it achieves "show other usages" behavior.
        })
      end,
      {
        desc = "LSP References",
        buffer = ev.buf,
      }
    )

    -- Lists all the implementations for the symbol under the cursor in the quickfix window.
    vim.keymap.set(
      "n",
      "gi",
      function()
        fzf_lua.lsp_implementations({
          ignore_current_line = true,
          jump1 = true,
        })
      end,
      {
        desc = "LSP Implementations",
        buffer = ev.buf,
      }
    )

    -- Selects a code action available at the current cursor position.
    vim.keymap.set(
      { "n", "v" },
      "<leader>ca",
      function()
        fzf_lua.lsp_code_actions()
      end,
      {
        desc = "LSP Code action",
        buffer = ev.buf,
      }
    )

    -- Live workspace symbols query
    vim.keymap.set(
      { "n", "v" },
      "<leader>ls",
      function()
        fzf_lua.lsp_live_workspace_symbols()
      end,
      {
        desc = "LSP Live Symbols",
        buffer = ev.buf,
      }
    )

    -- Displays hover information about the symbol under the cursor in a floating
    -- window. Calling the function twice will jump into the floating window.
    vim.keymap.set(
      "n",
      "K",
      vim.lsp.buf.hover,
      {
        desc = "LSP Hover",
        buffer = ev.buf,
      }
    )

    -- Displays signature information about the symbol under the cursor in a floating window.
    vim.keymap.set(
      "n",
      "<C-k>",
      vim.lsp.buf.signature_help,
      {
        desc = "LSP Signature help",
        buffer = ev.buf,
      }
    )

    -- Renames all references to the symbol under the cursor.
    vim.keymap.set(
      "n",
      "<leader>Rn",
      vim.lsp.buf.rename,
      {
        desc = "LSP Rename references",
        buffer = ev.buf,
      }
    )

    -- If a language server with semantic token capabilities is attached to a buffer (credit to @perrin4869)
    -- if hlargs then
    --   if not (ev.data and ev.data.client_id) then
    --     return
    --   end
    --
    --   local client = vim.lsp.get_client_by_id(ev.data.client_id)
    --   local caps = client.server_capabilities
    --   if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
    --     hlargs.disable_buf(ev.buf)
    --   end
    -- end
  end
})
