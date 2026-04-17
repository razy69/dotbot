-- Go development tools (test, debug, code generation)
plugin.add({
  name = "go",
  src = {
    "https://github.com/ray-x/guihua.lua",
    "https://github.com/ray-x/go.nvim",
  },
  ft = { "go", "gomod", "gowork", "godoc" },
  build = function(info)
    if info.name == "go.nvim" then
      require("go.install").update_all_sync()
    end
  end,
  config = function()
    require("go").setup({
      lsp_keymaps = false,                  -- keymaps handled by 03-lsp.lua
      lsp_inlay_hints = { enable = false }, -- inlay hints managed globally
      diagnostic = false,                   -- diagnostics managed globally
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = utils.augroup("go"),
      pattern = "*.go",
      callback = function()
        require("go.format").goimports()
      end,
    })
  end,
})
