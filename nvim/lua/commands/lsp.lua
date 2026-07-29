---@brief LSP management user commands. Built on top of built-in `vim.lsp.*`
--- APIs, so they have no dependency on any LSP-adjacent plugin (Mason,
--- lspconfig, etc.) and can live at startup.

-- Start
vim.api.nvim_create_user_command("LspStart", function()
  vim.cmd.e()
end, { desc = "Starts LSP clients in the current buffer" })

-- Stop
vim.api.nvim_create_user_command("LspStop", function(opts)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped", vim.log.levels.INFO)
    end
  end
end, {
  desc = "Stop all LSP clients or a specific client attached to the current buffer.",
  nargs = "?",
  complete = function(_, _, _)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

-- Restart
vim.api.nvim_create_user_command("LspRestart", function()
  -- Snapshot the attached buffers *before* stopping: `stop()` tears the
  -- list down, so reading client.attached_buffers afterwards could see it
  -- already empty and silently skip restarting that client.
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    local buffers = vim.tbl_keys(client.attached_buffers or {})
    if #buffers > 0 then
      detach_clients[client.name] = { config = client.config, id = client.id, buffers = buffers }
    end
    client:stop(true)
  end

  vim.wait(5000, function()
    for name, info in pairs(detach_clients) do
      -- Wait until the old client is genuinely gone before starting its
      -- replacement. vim.lsp.start() looks for a reuse_client match first,
      -- and a still-stopping client can still match — in which case it
      -- hands back the *dying* client's id, we attach buffers to it, report
      -- "restarted", and end up with no live server at all.
      if vim.lsp.get_client_by_id(info.id) == nil then
        local client_id = vim.lsp.start(info.config, { attach = false })
        if client_id then
          for _, buf in ipairs(info.buffers) do
            if vim.api.nvim_buf_is_valid(buf) then
              vim.lsp.buf_attach_client(buf, client_id)
            end
          end
          vim.notify(name .. ": restarted", vim.log.levels.INFO)
          detach_clients[name] = nil
        end
      end
    end
    return next(detach_clients) == nil
  end, 50)
  if next(detach_clients) then
    vim.notify("LspRestart: timed out waiting for servers", vim.log.levels.WARN)
  end
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
})

-- Log
vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = "Get all the lsp logs",
})

-- Info
vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("silent checkhealth vim.lsp")
end, {
  desc = "Get all the information about all LSP attached",
})

-- Log level. Derived from vim.log.levels rather than hand-written twice —
-- it is a plain name -> number map (no reverse entries), so the completion
-- list is just its keys sorted most-severe-first, matching the previous
-- hard-coded order: OFF, ERROR, WARN, INFO, DEBUG, TRACE.
local log_level_map = vim.deepcopy(vim.log.levels)
local log_levels = vim.tbl_keys(log_level_map)
table.sort(log_levels, function(a, b) return log_level_map[a] > log_level_map[b] end)

vim.api.nvim_create_user_command("LspLogLevel", function(opts)
  if opts.args == "" then
    local current = vim.lsp.log.get_level()
    for name, val in pairs(log_level_map) do
      if val == current then
        vim.notify("LSP log level: " .. name, vim.log.levels.INFO)
        return
      end
    end
    vim.notify("LSP log level: " .. tostring(current), vim.log.levels.INFO)
    return
  end
  local level = log_level_map[opts.args:upper()]
  if not level then
    vim.notify("Invalid level. Use: " .. table.concat(log_levels, ", "), vim.log.levels.ERROR)
    return
  end
  vim.lsp.log.set_level(level)
  vim.notify("LSP log level set to " .. opts.args:upper(), vim.log.levels.INFO)
end, {
  desc = "Get or set LSP log level",
  nargs = "?",
  complete = function()
    return log_levels
  end,
})
