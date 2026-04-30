-- LSP configuration: diagnostics, keymaps, Mason-driven server install.
-- Mason itself is set up in plugin/02-mason.lua and pulled in via deps.
plugin.add({
  name = "lsp",
  deps = { "mason" },
  event = plugin.LazyFile,
  src = {
    "https://github.com/Bekaboo/dropbar.nvim",
    "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
  },
  config = function()
    -- Collect server names from lsp/ filenames and enable them. vim.lsp.enable()
    -- loads each lsp/<name>.lua via the runtime, so no explicit dofile needed.
    -- SECURITY: Neovim's runtime will execute whatever lsp/*.lua it finds, so
    -- we gate on directory ownership+permissions before scanning.
    local lsp_configs_dir = vim.fn.stdpath("config") .. "/lsp"
    local server_names = {}
    if not utils.is_trusted_dir(lsp_configs_dir) then
      vim.notify(
        "lsp: refusing to scan " .. lsp_configs_dir .. " (not owned by current user or world-writable)",
        vim.log.levels.WARN
      )
    else
      for _, file in ipairs(vim.fn.readdir(lsp_configs_dir)) do
        if file:match("%.lua$") then
          table.insert(server_names, (file:gsub("%.lua$", "")))
        end
      end

      vim.lsp.enable(server_names)
    end

    -- Build Mason install list from resolved configs (avoids redundant dofile).
    -- Each lsp/<name>.lua may include an optional `mason` field when the Mason
    -- package name differs from cmd[1].
    local install_specs = {}
    for _, name in ipairs(server_names) do
      local cfg = vim.lsp.config[name]
      if cfg and cfg.cmd and cfg.cmd[1] then
        table.insert(install_specs, {
          pkg = cfg.mason or cfg.cmd[1],
          binary = cfg.cmd[1],
        })
      end
    end

    -- Declare install specs; actual install is gated behind :LspInstall to
    -- avoid unattended network fetches + package execution on startup.
    -- :MasonStatus lists what's missing; see lua/commands/mason.lua.
    local mason_cmds = require("commands.mason")
    mason_cmds.register("lsp", install_specs)
    mason_cmds.warn_missing("lsp")

    -- Merge default capabilities with blink.cmp completions, foldingRange support,
    -- and workspace file operation notifications (rename tracking).
    local blink_ok, blink_cmp = pcall(require, "blink.cmp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      blink_ok and blink_cmp.get_lsp_capabilities() or {},
      {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
          fileOperations = {
            didRename = true,
            willRename = true,
          },
          symbol = {
            dynamicRegistration = true,
            symbolKind = {
              valueSet = (function()
                local kinds = {}
                for i = 1, 26 do kinds[i] = i end
                return kinds
              end)(),
            },
            tagSupport = { valueSet = { 1 } },
            resolveSupport = {
              properties = { "location.range" },
            },
          },
        },
        textDocument = {
          completion = {
            completionItem = {
              snippetSupport = true,
            },
          },
          foldingRange = {
            dynamicRegistration = true,
            lineFoldingOnly = true,
          },
        },
      }
    )

    -- Config
    vim.lsp.config("*", {
      root_markers = { ".git" },
      capabilities = capabilities,
    })

    -- Autocmd
    local autocmd_lsp_group = utils.augroup("Lsp")

    vim.lsp.log.set_level(vim.log.levels.OFF)

    -- Fire `workspace/diagnostic` once per client so diagnostics are populated
    -- for files we never opened. Servers without native workspace pull
    -- support fall back to neonvim.workspace_diagnostics (a hidden-buffer
    -- scanner) when their lsp/<name>.lua sets `workspace_scan = true`.
    -- Servers that opt out get the standard push-on-open behaviour.
    -- Document pull is auto-enabled by Neovim when advertised
    -- (see vim/lsp.lua: lsp.diagnostic._enable).
    local workspace_diag_triggered = {}

    vim.api.nvim_create_autocmd("LspAttach", {
      group = autocmd_lsp_group,
      callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
          return
        end

        if not workspace_diag_triggered[client.id] then
          workspace_diag_triggered[client.id] = true
          if client:supports_method("workspace/diagnostic") then
            vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
          else
            local cfg = vim.lsp.config[client.name] or {}
            if cfg.workspace_scan == true then
              require("neonvim.workspace_diagnostics").schedule(client.id, bufnr)
            end
          end
        end

        -- Deferred requires (cached by Lua module system after first call)
        local fzf_lua = require("fzf-lua")
        local fzf_lua_actions = require("fzf-lua.actions")
        local hlargs = require("hlargs")

        -- Folding intentionally uses treesitter (set globally in options.lua),
        -- not LSP. Many servers report foldingRange with lineFoldingOnly in a
        -- way that excludes the closing `}` from the range (observed with
        -- gopls on `func outer() { return func() { … } }` — the outer brace
        -- stays visible when folded). Treesitter's fold queries capture the
        -- full syntactic node including trailing punctuation and behave
        -- consistently across languages.

        -- Use LSP for tag-based navigation (Ctrl-], :tag, etc.)
        if client:supports_method("textDocument/definition") then
          vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end

        -- Servers whose semantic tokens provide highlighting treesitter cannot
        -- replicate (e.g. read/write refs, package-level symbols). All other
        -- servers have semantic tokens disabled to avoid overriding treesitter.
        local keep_semantic_tokens = { "lua_ls" }
        local caps = client.server_capabilities
        if caps and caps.semanticTokensProvider and caps.semanticTokensProvider.full then
          if vim.tbl_contains(keep_semantic_tokens, client.name) then
            hlargs.disable_buf(bufnr)
          else
            client.server_capabilities.semanticTokensProvider = nil
          end
        end

        -- LSP keymaps (register once per buffer, not per-client attach).
        -- utils.wk_add works post-VimEnter (see lua/utils.lua); top-level
        -- wk.add would silently queue here since LspAttach fires after the
        -- which-key setup queue drain.
        if not vim.b[bufnr].lsp_keymaps_set then
          vim.b[bufnr].lsp_keymaps_set = true
          utils.wk_add({
            -- Declarations
            {
              "gD",
              function() fzf_lua.lsp_declarations({ sync = true, jump1 = true, jump1_action = fzf_lua_actions
                .file_vsplit }) end,
              desc = "LSP Go to declaration (vsplit)",
              buffer = bufnr,
              mode = "n"
            },
            {
              "gvD",
              function() fzf_lua.lsp_declarations({ sync = true, jump1 = true, jump1_action = fzf_lua_actions.file_split }) end,
              desc = "LSP Go to declaration (split)",
              buffer = bufnr,
              mode = "n"
            },
            -- Definitions
            {
              "gd",
              function()
                fzf_lua.lsp_definitions({
                  sync = true,
                  ignore_current_line = true,
                  jump1 = true,
                  jump1_action =
                      fzf_lua_actions.file_vsplit
                })
              end,
              desc = "LSP Go to definition (vsplit)",
              buffer = bufnr,
              mode = "n"
            },
            {
              "gvd",
              function()
                fzf_lua.lsp_definitions({
                  sync = true,
                  ignore_current_line = true,
                  jump1 = true,
                  jump1_action =
                      fzf_lua_actions.file_split
                })
              end,
              desc = "LSP Go to definition (split)",
              buffer = bufnr,
              mode = "n"
            },
            -- References (excludes current line and declaration for "show other usages" behavior)
            {
              "gr",
              function() fzf_lua.lsp_references({ ignore_current_line = true, includeDeclaration = false }) end,
              desc = "LSP References",
              buffer = bufnr,
              mode = "n"
            },
            -- Implementations
            {
              "gi",
              function() fzf_lua.lsp_implementations({ ignore_current_line = true, jump1 = true }) end,
              desc = "LSP Implementations",
              buffer = bufnr,
              mode = "n"
            },
            -- Workspace symbols
            {
              "<leader>ls",
              function() fzf_lua.lsp_live_workspace_symbols() end,
              desc = "LSP Live Symbols",
              buffer = bufnr,
              mode = { "n", "v" }
            },
            -- Hover with nesting. Opens the standard hover float; pressing K
            -- again inside the hover resolves the word under the cursor via
            -- workspace/symbol on this buffer's client and stacks another
            -- hover on top. `q` pops one level. See neonvim.nested_hover.
            {
              "K",
              function() require("neonvim.nested_hover").open() end,
              desc = "LSP Hover (nested)",
              buffer = bufnr,
              mode = "n",
            },
            -- Rename
            { "<leader>Rn", vim.lsp.buf.rename, desc = "LSP Rename references", buffer = bufnr, mode = "n" },
          })
        end
      end
    })

    -- Dispatch to either native pull (gopls et al.) or the simulated
    -- scan (neonvim.workspace_diagnostics) depending on what each
    -- attached client supports + opted into.
    vim.api.nvim_create_user_command("LspWorkspaceDiagnostics", function()
      local native, simulated = {}, {}
      for _, c in ipairs(vim.lsp.get_clients()) do
        if c:supports_method("workspace/diagnostic") then
          native[#native + 1] = c
        elseif (vim.lsp.config[c.name] or {}).workspace_scan == true then
          simulated[#simulated + 1] = c
        end
      end
      if #native == 0 and #simulated == 0 then
        vim.notify(
          "No attached LSP server supports workspace diagnostics (native or simulated)",
          vim.log.levels.WARN
        )
        return
      end
      if #native > 0 then
        vim.lsp.buf.workspace_diagnostics()
        local names = {}
        for _, c in ipairs(native) do names[#names + 1] = c.name end
        vim.notify("Workspace diagnostics requested: " .. table.concat(names, ", "), vim.log.levels.INFO)
      end
      if #simulated > 0 then
        local wd = require("neonvim.workspace_diagnostics")
        for _, c in ipairs(simulated) do
          wd.scan({ client_id = c.id })
        end
      end
    end, { desc = "Request workspace-wide LSP diagnostics (native or simulated)" })

    vim.api.nvim_create_user_command("LspWorkspaceScan", function()
      require("neonvim.workspace_diagnostics").scan()
    end, { desc = "Force a simulated workspace diagnostic scan for opted-in clients" })

    vim.api.nvim_create_user_command("LspWorkspaceScanCancel", function()
      require("neonvim.workspace_diagnostics").abort()
    end, { desc = "Cancel an in-progress simulated workspace scan" })

    vim.api.nvim_create_user_command("LspWorkspaceScanStatus", function()
      local s = require("neonvim.workspace_diagnostics").stats()
      vim.notify(string.format(
        "scope=%s · loaded=%d · pending=%d · %.1f MB · running=%s · paused=%s",
        s.scope or "?", s.loaded, s.pending, s.bytes_loaded / 1024 / 1024,
        tostring(s.running), tostring(s.paused)
      ), vim.log.levels.INFO)
    end, { desc = "Show simulated workspace scan statistics" })

    -- External edits (git pull, formatter ran outside Neovim, branch
    -- checkout) — re-stat loaded files and trigger reload for changed
    -- ones. Bounded; see neonvim.workspace_diagnostics.delta().
    vim.api.nvim_create_autocmd("FocusGained", {
      group = autocmd_lsp_group,
      callback = function()
        local ok, wd = pcall(require, "neonvim.workspace_diagnostics")
        if ok then wd.delta() end
      end,
    })

    -- Drop a client's queue when it detaches (server crashed, user :LspStop).
    vim.api.nvim_create_autocmd("LspDetach", {
      group = autocmd_lsp_group,
      callback = function(ev)
        local ok, wd = pcall(require, "neonvim.workspace_diagnostics")
        if ok and ev.data and ev.data.client_id then
          wd.detach(ev.data.client_id)
        end
      end,
    })

    -- Explicitly stop all LSP servers on exit to avoid orphaned processes;
    -- also tear down the workspace scan timer so libuv doesn't complain.
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = autocmd_lsp_group,
      pattern = "*",
      callback = function()
        local ok, wd = pcall(require, "neonvim.workspace_diagnostics")
        if ok then pcall(wd.cancel) end
        for _, client in ipairs(vim.lsp.get_clients()) do
          client:stop()
        end
      end,
    })


    -- Diagnostics (single authoritative config — signs are set in options.lua)
    vim.diagnostic.config({
      severity_sort = true,
      underline = false,
      update_in_insert = false,
      virtual_text = false, -- tiny-inline-diagnostic replaces virtual text
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
    })

    require("tiny-inline-diagnostic").setup({
      preset = "simple",
      signs = {
        diag = "●",
        arrow = "   ",
        up_arrow = " ",
      },
      options = {
        enable_on_insert = false,
        throttle = 20,
        set_arrow_to_diag_color = false,
        show_source = {
          enabled = true,
          if_many = false,
        },
        add_messages = {
          messages = true,
          display_count = true,
        },
        multilines = {
          enabled = true,
          always_show = true,
          trim_whitespaces = true,
        },
      },
    })
    vim.diagnostic.open_float = require("tiny-inline-diagnostic.override").open_float
  end,
})
