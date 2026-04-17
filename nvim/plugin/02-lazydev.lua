-- lazydev.nvim: auto-loads Neovim runtime + plugin types into lua-language-server
-- on demand (only when you `require("foo")`). ft-gated so it never loads for
-- non-Lua buffers. Blink.cmp references its integration module by string, so no
-- ordering constraint with blink.cmp — the require happens lazily when blink
-- queries completions on a Lua buffer.
plugin.add({
  name = "lazydev",
  src = "https://github.com/folke/lazydev.nvim",
  ft = { "lua" },
  config = function()
    require("lazydev").setup({
      library = {
        -- Async I/O types for vim.uv
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
})
