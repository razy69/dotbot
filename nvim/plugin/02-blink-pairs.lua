-- Auto-close brackets and quotes.
-- Prefixed 02- so this sources before plugin/03-blink-cmp.lua: blink.pairs
-- installs insert-mode <CR>/<BS>/<Space> keymaps that blink.cmp's keymap
-- chain captures as its "fallback". That's how <CR> between ({[ pairs gets
-- routed into blink.pairs' CR-split handler (blink.pairs/mappings/ops.lua:190).
-- Loaded synchronously as a dep of blink_cmp; no InsertEnter event needed.
plugin.add({
  name = "blink_pairs",
  src = {
    "https://github.com/saghen/blink.lib",
    { src = "https://github.com/saghen/blink.pairs", version = vim.version.range("*") },
  },
  build = function(info)
    if info.name == "blink.pairs" then
      -- Use build() (compile via cargo), not download(): blink.lib v0.6.0's
      -- download() is broken for dotted tags — it parses "v0.6.0" down to "0"
      -- (git_tag uses (%w+) which drops the dots), yielding a 404 URL, and its
      -- task never chains resolve/reject so it just hangs until timeout.
      -- build() avoids both bugs and needs only a Rust toolchain.
      require("blink.pairs").build():pwait(120000)
    end
  end,
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
