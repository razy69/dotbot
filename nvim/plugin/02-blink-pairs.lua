-- Auto-close brackets and quotes.
-- Prefixed 02- so this sources before plugin/03-blink-cmp.lua: blink.pairs
-- installs insert-mode <CR>/<BS>/<Space> keymaps that blink.cmp's keymap
-- chain captures as its "fallback". That's how <CR> between ({[ pairs gets
-- routed into blink.pairs' CR-split handler (blink.pairs/mappings/ops.lua:190).
-- Ordering is guaranteed by `deps`, not by the filename prefix: blink_cmp
-- declares blink_pairs as a dependency and dependency resolution is always
-- synchronous, so pairs' mappings exist before blink.cmp builds its keymap
-- chain. `lazy` keeps that off the startup path — this file was the single
-- most expensive one sourced at startup (~7ms), mostly the download() probe.
plugin.add({
  name = "blink_pairs",
  lazy = true,
  src = {
    "https://github.com/saghen/blink.lib",
    { src = "https://github.com/saghen/blink.pairs", version = vim.version.range("*") },
  },
  config = function()
    -- blink.pairs v0.6+ loads a native parser lib. For vim.pack the lib must be
    -- present before setup() (setup() errors otherwise), so we ensure it here
    -- on every startup rather than only from a PackChanged build hook.
    -- download() fetches the prebuilt binary (no Rust toolchain) and is a cheap
    -- idempotent no-op once the matching version is installed — after an update
    -- the lib filename embeds the git commit, so a version bump re-fetches
    -- automatically.
    require("blink.pairs").download():pwait(60000)
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
