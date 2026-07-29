-- Debugger
plugin.add({
  name = "dap",
  src = {
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/leoluz/nvim-dap-go",
    "https://github.com/igorlfs/nvim-dap-view",
  },
  -- Every key registered in config() must be listed here, otherwise it stays
  -- dead until one of the listed keys loads the plugin.
  keys = {
    { "<leader>db", desc = "toggle debug breakpoint" },
    { "<leader>dB", desc = "debug breakpoint condition" },
    { "<leader>dc", desc = "debug continue" },
    { "<leader>dC", desc = "debug to cursor" },
    { "<leader>dg", desc = "debug go to line" },
    { "<leader>do", desc = "debug step over" },
    { "<leader>dO", desc = "debug step out" },
    { "<leader>di", desc = "debug step into" },
    { "<leader>dj", desc = "debug jump down" },
    { "<leader>dk", desc = "debug jump up" },
    { "<leader>dl", desc = "debug last" },
    { "<leader>dp", desc = "debug pause" },
    { "<leader>dr", desc = "debug repl" },
    { "<leader>dR", desc = "debug remove breakpoints" },
    { "<leader>dt", desc = "debug terminate" },
    { "<leader>dv", desc = "dap view" },
  },
  config = function()
    local dap = require("dap")
    local dap_view = require("dap-view")
    dap_view.setup({
      winbar = {
        controls = {
          enabled = true,
        },
      },
      virtual_text = {
        enabled = true,
      },
    })
    require("dap-go").setup()

    -- nvim-dap-go's default `Debug` and `Debug test` pass `${file}` to delve,
    -- which compiles only that single file as `command-line-arguments` — so
    -- symbols from sibling files in the same package appear undefined. Point
    -- them at the containing directory so delve sees the whole package.
    for _, cfg in ipairs(dap.configurations.go or {}) do
      if cfg.program == "${file}" then
        cfg.program = "${fileDirname}"
      end
    end

    -- Auto-open/close dap-view on DAP session lifecycle
    dap.listeners.before.attach["dap-view"] = function() dap_view.open() end
    dap.listeners.before.launch["dap-view"] = function() dap_view.open() end
    dap.listeners.before.event_terminated["dap-view"] = function() dap_view.close() end
    dap.listeners.before.event_exited["dap-view"] = function() dap_view.close() end

    -- Make the dap-view play button work for initial launch, not just resume.
    -- Without this wrapper, clicking play with no active session errors with
    -- "No configuration found for `dap-view`" because dap.continue() reads
    -- configurations by the current buffer's filetype, which is `dap-view`.
    -- We redirect the call to the most recently used code window.
    local orig_continue = dap.continue
    ---@diagnostic disable-next-line: duplicate-set-field
    dap.continue = function(opts)
      if dap.session() == nil and vim.bo.filetype == "dap-view" then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft ~= "dap-view" and ft ~= "dap-repl" and ft ~= "" then
            return vim.api.nvim_win_call(win, function()
              return orig_continue(opts)
            end)
          end
        end
      end
      return orig_continue(opts)
    end

    -- Add keymap
    utils.wk_add({
      { "<leader>db", function() dap.toggle_breakpoint() end,                                    desc = "toggle [d]ebug [b]reakpoint",     mode = { "n" } },
      { "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "[d]ebug [B]reakpoint",            mode = { "n" } },
      { "<leader>dc", function() dap.continue() end,                                             desc = "[d]ebug [c]ontinue (start here)", mode = { "n" } },
      { "<leader>dC", function() dap.run_to_cursor() end,                                        desc = "[d]ebug [C]ursor",                mode = { "n" } },
      { "<leader>dg", function() dap.goto_() end,                                                desc = "[d]ebug [g]o to line",            mode = { "n" } },
      { "<leader>do", function() dap.step_over() end,                                            desc = "[d]ebug step [o]ver",             mode = { "n" } },
      { "<leader>dO", function() dap.step_out() end,                                             desc = "[d]ebug step [O]ut",              mode = { "n" } },
      { "<leader>di", function() dap.step_into() end,                                            desc = "[d]ebug [i]nto",                  mode = { "n" } },
      { "<leader>dj", function() dap.down() end,                                                 desc = "[d]ebug [j]ump down",             mode = { "n" } },
      { "<leader>dk", function() dap.up() end,                                                   desc = "[d]ebug jump up ([k])",           mode = { "n" } },
      { "<leader>dl", function() dap.run_last() end,                                             desc = "[d]ebug [l]ast",                  mode = { "n" } },
      { "<leader>dp", function() dap.pause() end,                                                desc = "[d]ebug [p]ause",                 mode = { "n" } },
      { "<leader>dr", function() dap.repl.toggle() end,                                          desc = "[d]ebug [r]epl",                  mode = { "n" } },
      { "<leader>dR", function() dap.clear_breakpoints() end,                                    desc = "[d]ebug [R]emove breakpoints",    mode = { "n" } },
      { "<leader>dt", function() dap.terminate() end,                                            desc = "[d]ebug [t]erminate",             mode = { "n" } },
      { "<leader>dv", function() dap_view.toggle() end,                                          desc = "[d]ap [v]iew",                    mode = { "n" } },
    })
  end
})
