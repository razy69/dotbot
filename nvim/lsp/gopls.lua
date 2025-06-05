local async = require("config.async")
local mod_cache = nil

---@type vim.lsp.Config
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = function(fname)
    -- see: https://github.com/neovim/nvim-lspconfig/issues/804
    if not mod_cache then
      local result = async.run_command { "go", "env", "GOMODCACHE" }
      if result and result[1] then
        mod_cache = vim.trim(result[1])
      else
        mod_cache = vim.fn.system "go env GOMODCACHE"
      end
    end
    if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
      local clients = vim.lsp.get_clients { name = "gopls" }
      if #clients > 0 then
        return clients[#clients].config.root_dir
      end
    end
    return vim.fs.root(0, {
      "go.work",
      "go.mod",
      ".git",
    })
  end,
  single_file_support = true,
}
