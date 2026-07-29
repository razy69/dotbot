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
    -- (minus .lua) is the nvim-lint linter name. The spec may override
    -- `package` (Mason package name) and `binary` (executable on PATH)
    -- when they differ from the linter name — same shape as lsp/. An
    -- optional `customize(linter)` callback gets the resolved nvim-lint
    -- linter table for last-mile tweaks (e.g. injecting --config args).
    -- SECURITY: dofile() would execute any .lua dropped here, so we gate
    -- on ownership+permissions before scanning.
    local lint_specs = {}
    local customizers = {}
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
          table.insert(lint_specs, {
            pkg = spec.package or name,
            binary = spec.binary or name,
          })
          -- Guard `ft`: a spec missing it would throw here, and because this runs
          -- inside config() the failure would take down the whole nvim-lint
          -- setup (autocmds, :Lint, keymap) rather than just that one linter.
          if type(spec.ft) ~= "table" then
            vim.notify(
              ("nvim-lint: linters/%s is missing an `ft` list; skipped"):format(file),
              vim.log.levels.WARN
            )
          else
            for _, ft in ipairs(spec.ft) do
              linters_by_ft[ft] = linters_by_ft[ft] or {}
              table.insert(linters_by_ft[ft], name)
            end
          end
          if type(spec.customize) == "function" then
            customizers[name] = spec.customize
          end
        end
      end
    end

    lint.linters_by_ft = linters_by_ft

    -- Apply customizers after linters_by_ft is wired so the linter table
    -- has been resolved via lint.linters[name] (which lazy-loads the
    -- built-in spec from nvim-lint's package).
    for name, fn in pairs(customizers) do
      local linter = lint.linters[name]
      if linter then
        local ok, err = pcall(fn, linter)
        if not ok then
          vim.notify(
            ("nvim-lint: customize(%s) failed: %s"):format(name, err),
            vim.log.levels.WARN
          )
        end
      end
    end

    -- Declare install specs; actual install is gated behind :LintInstall to
    -- avoid unattended network fetches + package execution on startup.
    -- :MasonStatus lists what's missing; see lua/commands/mason.lua.
    local mason_cmds = require("commands.mason")
    mason_cmds.register("lint", lint_specs)
    mason_cmds.warn_missing("lint")

    -- Auto-lint on file open and save (BufReadPost, not BufEnter, to avoid
    -- re-spawning linter subprocesses on every buffer/split switch).
    -- Debounced per-buffer: rapid saves (e.g. :wa across many buffers) or
    -- format-on-save followed by BufWritePost collapse into a single run.
    local lint_timers = {}
    local LINT_DEBOUNCE_MS = 250
    local lint_group = utils.augroup("lint")
    -- Only lint real on-disk files. LSP hover popups, snacks docs, and other
    -- ephemeral UI buffers may carry a linted filetype (markdown, lua, …) but
    -- have a non-empty buftype or no backing file — running a linter there is
    -- noise at best and breaks rendering at worst.
    local function is_real_file_buf(buf)
      if vim.bo[buf].buftype ~= "" then
        return false
      end
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then
        return false
      end
      return vim.uv.fs_stat(name) ~= nil
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = lint_group,
      callback = function(ev)
        if not is_real_file_buf(ev.buf) then
          return
        end
        local t = lint_timers[ev.buf]
        if t then
          t:stop()
          t:close()
        end
        lint_timers[ev.buf] = vim.defer_fn(function()
          lint_timers[ev.buf] = nil
          if vim.api.nvim_buf_is_valid(ev.buf) and is_real_file_buf(ev.buf) then
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
