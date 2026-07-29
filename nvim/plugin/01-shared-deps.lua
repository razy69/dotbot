-- Shared library dependencies used by multiple plugins.
-- Registered here so consumers reference them via deps = { "plenary" } etc.
-- instead of duplicating the src URL in every spec.
--
-- `lazy = true` keeps them off the startup path: every consumer declares them
-- in `deps`, and dependency resolution always loads synchronously, so they are
-- guaranteed to be on the rtp before the consumer's config() runs.
plugin.add({
  name = "plenary",
  lazy = true,
  src = "https://github.com/nvim-lua/plenary.nvim",
})

plugin.add({
  name = "nvim_nio",
  lazy = true,
  src = "https://github.com/nvim-neotest/nvim-nio",
})
