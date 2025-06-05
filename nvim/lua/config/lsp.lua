--[[
  File: lsp_.lua
  Description: Configure LSP, capabilities, commands, keymap, diagnostics..
]]

local utils = require("config.utils")


-- Capabilities
local blink = utils.prequire("blink.cmp")
local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  blink and blink.get_lsp_capabilities() or {},
  {
    workspace = {
      fileOperations = {
        didRename = true,
        willRename = true,
      },
    },
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
  }
)


-- Config
vim.lsp.config("*", {
  capabilities = capabilities,
})


-- Autocmd
local autocmd = require("config.autocmd")
local fzf_lua = utils.prequire("fzf-lua")
local fzf_lua_actions = utils.prequire("fzf-lua.actions")
local hlargs = utils.prequire("hlargs")

local autocmd_lsp_group = autocmd.augroup("Lsp")

vim.api.nvim_create_autocmd("LspAttach", {
  group = autocmd_lsp_group,
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- If a language server with semantic token capabilities is attached to a buffer (credit to @perrin4869)
    if hlargs then
      local caps = client.server_capabilities
      if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
        hlargs.disable_buf(bufnr)
      end
    end

    if fzf_lua and fzf_lua_actions then
      -- Jumps to the declaration of the symbol under the cursor.
      vim.keymap.set(
        "n",
        "gD",
        function()
          fzf_lua.lsp_declarations({
            sync = true,
            jump1 = true,
            jump1_action = fzf_lua_actions.file_vsplit,
          })
        end,
        {
          desc = "LSP Go to declaration",
          buffer = bufnr,
        }
      )
      vim.keymap.set(
        "n",
        "gvD",
        function()
          fzf_lua.lsp_declarations({
            sync = true,
            jump1 = true,
            jump1_action = fzf_lua_actions.file_split,
          })
        end,
        {
          desc = "LSP Go to declaration",
          buffer = bufnr,
        }
      )

      -- Jumps to the definition of the symbol under the cursor.
      vim.keymap.set(
        "n",
        "gd",
        function()
          fzf_lua.lsp_definitions({
            sync = true,
            ignore_current_line = true,
            jump1 = true,
            jump1_action = fzf_lua_actions.file_vsplit,
          })
        end,
        {
          desc = "LSP Go to definition (vsplit)",
          buffer = bufnr,
        }
      )
      vim.keymap.set(
        "n",
        "gvd",
        function()
          fzf_lua.lsp_definitions({
            sync = true,
            ignore_current_line = true,
            jump1 = true,
            jump1_action = fzf_lua_actions.file_split,
          })
        end,
        {
          desc = "LSP Go to definition (split)",
          buffer = bufnr,
        }
      )

      -- Lists all the references to the symbol under the cursor in the quickfix window.
      vim.keymap.set(
        "n",
        "gr",
        function()
          fzf_lua.lsp_references({
            ignore_current_line = true,
            includeDeclaration = false, -- Combined with ignore_current_line = true, it achieves "show other usages" behavior.
          })
        end,
        {
          desc = "LSP References",
          buffer = bufnr,
        }
      )

      -- Lists all the implementations for the symbol under the cursor in the quickfix window.
      vim.keymap.set(
        "n",
        "gi",
        function()
          fzf_lua.lsp_implementations({
            ignore_current_line = true,
            jump1 = true,
          })
        end,
        {
          desc = "LSP Implementations",
          buffer = bufnr,
        }
      )

      -- Selects a code action available at the current cursor position.
      vim.keymap.set(
        { "n", "v" },
        "<leader>ca",
        function()
          fzf_lua.lsp_code_actions()
        end,
        {
          desc = "LSP Code action",
          buffer = bufnr,
        }
      )

      -- Live workspace symbols query
      vim.keymap.set(
        { "n", "v" },
        "<leader>ls",
        function()
          fzf_lua.lsp_live_workspace_symbols()
        end,
        {
          desc = "LSP Live Symbols",
          buffer = bufnr,
        }
      )
    end

    -- Displays hover information about the symbol under the cursor in a floating
    -- window. Calling the function twice will jump into the floating window.
    vim.keymap.set(
      "n",
      "K",
      vim.lsp.buf.hover,
      {
        desc = "LSP Hover",
        buffer = bufnr,
      }
    )

    -- Renames all references to the symbol under the cursor.
    vim.keymap.set(
      "n",
      "<leader>Rn",
      vim.lsp.buf.rename,
      {
        desc = "LSP Rename references",
        buffer = bufnr,
      }
    )
  end
})

-- Kill LSP servers when leaving Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = autocmd_lsp_group,
  pattern = "*",
  callback = function()
    vim.iter(vim.lsp.get_clients()):each(
      function(client)
        client:stop()
      end
    )
  end,
})


-- Diagnostics
vim.diagnostic.config({
  severity_sort = true,
  underline = false,
  update_in_insert = false,
  virtual_box = true,
  virtual_text = {
    spacing = 4,
    prefix = "▎",
    source = "if_many",
    format = function(diagnostic)
      return string.format(
        "%s (%s: %s)",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code
      )
    end,
  },
  float = {
    border = "none",
    format = function(diagnostic)
      return string.format(
        "%s (%s: %s)",
        diagnostic.message,
        diagnostic.source,
        diagnostic.code
      )
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    texthl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})


-- Commands
vim.api.nvim_create_user_command("LspStart", function()
  vim.cmd.e()
end, { desc = "Starts LSP clients in the current buffer" })

vim.api.nvim_create_user_command("LspStop", function(opts)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped")
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

vim.api.nvim_create_user_command("LspRestart", function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify("Servers are stopped but havent been restarted")
  end
  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })
        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end
          vim.notify(name .. ": restarted")
        end
        detach_clients[name] = nil
      end
      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = "Get all the lsp logs",
})

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("silent checkhealth vim.lsp")
end, {
  desc = "Get all the information about all LSP attached",
})
