-- Provides a simple way to run and visualize code actions
plugin.add({
  name = "tiny_code_action",
  src = "https://github.com/rachartier/tiny-code-action.nvim",
  -- No plenary dep: tiny-code-action.nvim/lua/ contains no plenary require.
  deps = { "fzf_lua" },
  -- <leader>ca is the only entry point, so LspAttach was dragging in fzf-lua
  -- and the delta backend for every session where no code action is requested.
  keys = {
    { "<leader>ca", desc = "LSP code action" },
  },
  config = function()
    local code_action = require("tiny-code-action")

    code_action.setup({
      backend = "delta",
      picker = "fzf-lua",
    })

    -- Add keymap
    utils.wk_add({
      { "<leader>ca", function() code_action.code_action({}) end, desc = "LSP [C]ode [A]ction", mode = { "n" } },
    })
  end
})
