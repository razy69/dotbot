--[[
  File: neotest_.lua
  Description: Tests utils
  Link: https://github.com/nvim-neotest/neotest
]]

local dap = require("dap")
local dapui = require("dapui")

dapui.setup({})
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end

require("dap-go").setup({
  dap_configurations = {
    {
      type = "go",
      name = "Debug (Build Flags & Arguments)",
      request = "launch",
      program = "${file}",
      args = require("dap-go").get_arguments,
      buildFlags = require("dap-go").get_build_flags,
    },
  }
})

local neotest_golang_opts = {
  sanitize_output = true,
}
require("neotest").setup({
  adapters = {
    require("neotest-golang")(neotest_golang_opts), -- Registration
  },
})
