-- Auto-close brackets and quotes.
-- Prefixed 02- so this sources before plugin/03-blink-cmp.lua: blink.pairs
-- installs insert-mode <CR>/<BS>/<Space> keymaps that blink.cmp's keymap
-- chain captures as its "fallback". That's how <CR> between ({[ pairs gets
-- routed into blink.pairs' CR-split handler (blink.pairs/mappings/ops.lua:190).
-- Loaded synchronously as a dep of blink_cmp; no InsertEnter event needed.
plugin.add({
  name = "blink_pairs",
  src = {
    "https://github.com/saghen/blink.download",
    { src = "https://github.com/saghen/blink.pairs", version = vim.version.range("0") },
  },
  config = function()
    require("blink.pairs").setup({
      mappings = {
        enabled = true,
        cmdline = false,
      },
      highlights = {
        enabled = true,
        cmdline = false,
      },
    })
  end,
})
