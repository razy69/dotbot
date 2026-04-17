-- Provides a simple way to run and visualize code actions
plugin.add({
  name = "tiny_code_action",
  src = "https://github.com/rachartier/tiny-code-action.nvim",
  deps = { "plenary", "fzf_lua" },
  event = { "LspAttach" },
  config = function()
    local code_action = require("tiny-code-action")

    code_action.setup({
      backend = "delta",
      picker = "fzf-lua",
    })

    -- Add keymap
    utils.wk_add({
      { "<leader>ca", function() code_action.code_action() end, desc = "LSP [C]ode [A]ction", mode = { "n" } },
    })
  end
})
