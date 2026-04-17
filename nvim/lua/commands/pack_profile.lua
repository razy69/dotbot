---@brief `:PackProfile` — startup profile viewer (mimics `:Lazy profile`).
--- Reads timing data populated by `lua/plugin.lua` (exposed as `_G.plugin`)
--- and renders milestones + a sorted bar chart of per-plugin load durations.

--- Render the startup profile (milestones + per-plugin load timings) into
--- a list of lines, mimicking `:Lazy profile`. Reads from the `M.timings`
--- and `M.milestones` tables that lua/plugin.lua populates as plugins load.
---@return string[] lines
local function build_profile_lines()
  local timings = vim.deepcopy(plugin.timings or {})
  local ms = plugin.milestones or {}
  local now_ms = (vim.uv.hrtime() - plugin._t0) / 1e6

  table.sort(timings, function(a, b) return a.dur_ms > b.dur_ms end)

  local total_load = 0
  local config_load = 0
  for _, t in ipairs(timings) do
    total_load = total_load + t.dur_ms
    config_load = config_load + t.config_ms
  end

  local lines = {}
  table.insert(lines, "Startup profile")
  table.insert(lines, string.rep("─", 78))
  table.insert(lines, "")
  table.insert(lines, "  Milestones (ms since plugin module loaded)")
  if ms.vim_enter then
    table.insert(lines, ("    VimEnter:                %8.2f ms"):format(ms.vim_enter))
  end
  if ms.ui_enter then
    table.insert(lines, ("    UIEnter:                 %8.2f ms"):format(ms.ui_enter))
  end
  table.insert(lines, ("    Now:                     %8.2f ms"):format(now_ms))
  table.insert(lines, "")
  table.insert(lines, ("  Plugins loaded:            %8d"):format(#timings))
  table.insert(lines, ("  Plugin loads (sum):        %8.2f ms"):format(total_load))
  table.insert(lines, ("    of which config():       %8.2f ms"):format(config_load))
  table.insert(lines, "")

  if #timings == 0 then
    table.insert(lines, "  No plugins have loaded yet.")
    return lines
  end

  -- Bar chart: width proportional to dur_ms / max_dur
  local max_dur = timings[1].dur_ms
  local max_name = 0
  for _, t in ipairs(timings) do
    if #t.name > max_name then max_name = #t.name end
  end
  local max_trigger = 0
  for _, t in ipairs(timings) do
    if #t.trigger > max_trigger then max_trigger = #t.trigger end
  end
  local bar_width = 24

  table.insert(lines, "Plugin load durations (sorted desc)")
  table.insert(lines, string.rep("─", 78))
  table.insert(lines, ("  %-" .. bar_width .. "s  %-" .. max_name .. "s   %9s   %9s  %s"):format(
    "", "plugin", "total", "config", "trigger"
  ))
  for _, t in ipairs(timings) do
    local bar_len = math.max(1, math.floor((t.dur_ms / max_dur) * bar_width))
    local bar = string.rep("▇", bar_len) .. string.rep(" ", bar_width - bar_len)
    table.insert(lines, ("  %s  %-" .. max_name .. "s  %7.2f ms  %7.2f ms  [%s]"):format(
      bar, t.name, t.dur_ms, t.config_ms, t.trigger
    ))
  end

  return lines
end

--- :PackProfile — open a buffer showing startup milestones and a sorted
--- bar chart of per-plugin load durations (similar to :Lazy profile).
vim.api.nvim_create_user_command("PackProfile", function(ctx)
  -- --json: export profile data as JSON (copied to clipboard)
  if ctx.args == "--json" then
    local data = {
      milestones = plugin.milestones or {},
      now_ms = (vim.uv.hrtime() - plugin._t0) / 1e6,
      timings = plugin.timings or {},
    }
    local json = vim.json.encode(data)
    vim.fn.setreg("+", json)
    vim.notify("PackProfile JSON copied to clipboard", vim.log.levels.INFO)
    return
  end

  local lines = build_profile_lines()
  vim.cmd("botright new")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "packprofile"
  pcall(vim.api.nvim_buf_set_name, bufnr, "PackProfile")
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.wrap = false
  vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = bufnr, silent = true, desc = "Close PackProfile" })
end, { desc = "Show startup profile (per-plugin load timings)", nargs = "?",
  complete = function() return { "--json" } end,
})
