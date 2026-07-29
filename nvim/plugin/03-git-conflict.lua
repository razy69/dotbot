-- Visualise and resolve conflicts.
--
-- git-conflict registers per-buffer autocmds and looks for conflict markers on
-- every file you open, in every repo, forever — for a feature that only matters
-- mid-merge. So the file trigger is armed only when the repo is actually in a
-- conflicted state; otherwise the commands below load it on demand.
--
-- Only a real `.git` directory is probed: in a linked worktree or submodule
-- `.git` is a file pointing elsewhere, so those fall back to command-only.
local function merge_in_progress()
  local root = vim.fs.root(0, ".git")
  if not root then
    return false
  end
  for _, marker in ipairs({
    "MERGE_HEAD", "REBASE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD",
    "rebase-merge", "rebase-apply",
  }) do
    if vim.uv.fs_stat(vim.fs.joinpath(root, ".git", marker)) then
      return true
    end
  end
  return false
end

plugin.add({
  name = "git_conflict",
  src = "https://github.com/akinsho/git-conflict.nvim",
  event = merge_in_progress() and plugin.LazyFile or nil,
  cmd = {
    "GitConflictListQf",
    "GitConflictChooseOurs",
    "GitConflictChooseTheirs",
    "GitConflictChooseBoth",
    "GitConflictChooseNone",
    "GitConflictNextConflict",
    "GitConflictPrevConflict",
    "GitConflictRefresh",
  },
  config = function()
    require("git-conflict").setup({})
  end
})
