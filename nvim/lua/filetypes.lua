vim.filetype.add({
  filename = {
    [".git/config"] = "gitconfig",
  },
})

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > vim.g.bigfile_size
            and "bigfile"
            or nil
      end,
    },
  },
})
