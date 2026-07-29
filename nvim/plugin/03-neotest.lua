-- Tests runner
plugin.add({
  name = "neotest",
  src = {
    "https://github.com/fredrikaverpil/neotest-golang",
    "https://github.com/nvim-neotest/neotest",
  },
  deps = { "nvim_nio", "plenary", "dap" },
  -- Every key registered in config() must be listed here, otherwise it stays
  -- dead until one of the listed keys loads the plugin.
  keys = {
    { "<leader>ta", desc = "test attach" },
    { "<leader>tA", desc = "test all files" },
    { "<leader>td", desc = "debug nearest test" },
    { "<leader>tD", desc = "debug current file" },
    { "<leader>tf", desc = "test file" },
    { "<leader>tl", desc = "test last" },
    { "<leader>tn", desc = "test nearest" },
    { "<leader>to", desc = "test output" },
    { "<leader>tO", desc = "test output panel" },
    { "<leader>ts", desc = "test summary" },
    { "<leader>tS", desc = "test suite" },
    { "<leader>tt", desc = "test terminate" },
  },
  config = function()
    -- Configure neotest
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message =
              diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    local neotest = require("neotest")
    neotest.setup({
      adapters = {
        require("neotest-golang")({
          dap_go_enabled = true,
        }),
      },
    })

    -- Add Keymap
    utils.wk_add({
      { "<leader>ta", function() neotest.run.attach() end,                                      desc = "[t]est [a]ttach",          mode = { "n" } },
      { "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end,                       desc = "[t]est run [f]ile",        mode = { "n" } },
      { "<leader>tA", function() neotest.run.run(vim.uv.cwd()) end,                             desc = "[t]est [A]ll files",       mode = { "n" } },
      { "<leader>tS", function() neotest.run.run({ suite = true }) end,                         desc = "[t]est [S]uite",           mode = { "n" } },
      { "<leader>tn", function() neotest.run.run() end,                                         desc = "[t]est [n]earest",         mode = { "n" } },
      { "<leader>tl", function() neotest.run.run_last() end,                                    desc = "[t]est [l]ast",            mode = { "n" } },
      { "<leader>ts", function() neotest.summary.toggle() end,                                  desc = "[t]est [s]ummary",         mode = { "n" } },
      { "<leader>to", function() neotest.output.open({ enter = true, auto_close = true }) end,  desc = "[t]est [o]utput",          mode = { "n" } },
      { "<leader>tO", function() neotest.output_panel.toggle() end,                             desc = "[t]est [O]utput panel",    mode = { "n" } },
      { "<leader>tt", function() neotest.run.stop() end,                                        desc = "[t]est [t]erminate",       mode = { "n" } },
      { "<leader>td", function() neotest.run.run({ suite = false, strategy = "dap" }) end,      desc = "Debug nearest test",       mode = { "n" } },
      { "<leader>tD", function() neotest.run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Debug current file",       mode = { "n" } },
    })
  end
})
