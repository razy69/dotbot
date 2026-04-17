-- Async linter (complements conform.nvim for formatting)
plugin.add({
  name = "nvim_lint",
  src = "https://github.com/mfussenegger/nvim-lint",
  event = plugin.LazyFile,
  deps = { "mason" },
  config = function()
    local lint = require("lint")

    -- System-shell linters (not Mason packages, resolved from PATH).
    local linters_by_ft = {
      bash = { "bash" },
      zsh = { "zsh" },
    }

    -- Scan linters/ for Mason-installable linter definitions. Filename
    -- (minus .lua) is the source of truth for both the nvim-lint linter
    -- name and the Mason package name — same contract as lsp/.
    -- SECURITY: dofile() would execute any .lua dropped here, so we gate
    -- on ownership+permissions before scanning.
    local mason_linters = {}
    local linters_dir = vim.fn.stdpath("config") .. "/linters"
    if not utils.is_trusted_dir(linters_dir) then
      vim.notify(
        "nvim-lint: refusing to scan " .. linters_dir .. " (not owned by current user or world-writable)",
        vim.log.levels.WARN
      )
    else
      for _, file in ipairs(vim.fn.readdir(linters_dir)) do
        if file:match("%.lua$") then
          local name = file:gsub("%.lua$", "")
          local spec = dofile(linters_dir .. "/" .. file)
          table.insert(mason_linters, name)
          for _, ft in ipairs(spec.ft) do
            linters_by_ft[ft] = linters_by_ft[ft] or {}
            table.insert(linters_by_ft[ft], name)
          end
        end
      end
    end

    lint.linters_by_ft = linters_by_ft

    -- Declare install specs; actual install is gated behind :LintInstall to
    -- avoid unattended network fetches + package execution on startup.
    -- :MasonStatus lists what's missing; see lua/commands/mason.lua.
    local mason_cmds = require("commands.mason")
    local lint_specs = {}
    for _, name in ipairs(mason_linters) do
      table.insert(lint_specs, { package = name, binary = name })
    end
    mason_cmds.register("lint", lint_specs)
    mason_cmds.warn_missing("lint")

    -- Auto-lint on file open and save (BufReadPost, not BufEnter, to avoid
    -- re-spawning linter subprocesses on every buffer/split switch).
    -- Debounced per-buffer: rapid saves (e.g. :wa across many buffers) or
    -- format-on-save followed by BufWritePost collapse into a single run.
    local lint_timers = {}
    local LINT_DEBOUNCE_MS = 250
    local lint_group = utils.augroup("lint")
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = lint_group,
      callback = function(ev)
        local t = lint_timers[ev.buf]
        if t then
          t:stop()
          t:close()
        end
        lint_timers[ev.buf] = vim.defer_fn(function()
          lint_timers[ev.buf] = nil
          if vim.api.nvim_buf_is_valid(ev.buf) then
            vim.api.nvim_buf_call(ev.buf, function()
              lint.try_lint()
            end)
          end
        end, LINT_DEBOUNCE_MS)
      end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
      group = lint_group,
      callback = function(ev)
        local t = lint_timers[ev.buf]
        if t then
          t:stop()
          t:close()
          lint_timers[ev.buf] = nil
        end
      end,
    })

    -- Manual lint command
    vim.api.nvim_create_user_command("Lint", function()
      vim.notify("Linting buffer...", vim.log.levels.INFO)
      lint.try_lint()
    end, { desc = "Lint current buffer" })

    utils.wk_add({
      { "<leader>cl", "<cmd>Lint<cr>", desc = "Lint buffer", mode = "n" },
    })
  end,
})
