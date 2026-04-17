-- Shared library dependencies used by multiple plugins.
-- Registered here so consumers reference them via deps = { "plenary" } etc.
-- instead of duplicating the src URL in every spec.
plugin.add({
  name = "plenary",
  src = "https://github.com/nvim-lua/plenary.nvim",
})

plugin.add({
  name = "nvim_nio",
  src = "https://github.com/nvim-neotest/nvim-nio",
})
