-- Visualise and resolve conflicts
plugin.add({
  name = "git_conflict",
  src = "https://github.com/akinsho/git-conflict.nvim",
  event = plugin.LazyFile,
  config = function()
    require("git-conflict").setup({})
  end
})
