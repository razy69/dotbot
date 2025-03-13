--[[
  File: neotest._lua
  Description:
  Link:
]]

local utils = require("config.utils")

local adapters = {
  ["neotest-golang"] = {
    sanitize_output = true,
    go_test_args = {
      "-v",
      "-count=1",
      "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
    },
  }
}

for name, config in pairs(adapters) do
  if type(name) == "number" then
    if type(config) == "string" then
      config = require(config)
    end
    adapters[#adapters + 1] = config
  elseif config ~= false then
    local adapter = require(name)
    if type(config) == "table" and not vim.tbl_isempty(config) then
      local meta = getmetatable(adapter)
      if adapter.setup then
        adapter.setup(config)
      elseif adapter.adapter then
        adapter.adapter(config)
        adapter = adapter.adapter
      elseif meta and meta.__call then
        adapter(config)
      else
        error("Adapter " .. name .. " does not support setup")
      end
    end
    adapters[#adapters + 1] = adapter
  end
end

local dap_go = utils.prequire("dap-go")
if dap_go then
  dap_go.setup()
end

local coverage
if coverage then
  coverage.setup({
    auto_reload = true,
    signs = {
      covered = { text = "┋" },
      uncovered = { text = "┋" },
    }
  })
end

require("neotest").setup({ adapters = adapters })
