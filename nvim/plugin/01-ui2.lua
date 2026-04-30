-- Custom cmdline + ui2 messages (replaces Noice). Loaded on UIEnter so
-- ui2's nvim_list_uis() guard passes.
--
-- Architecture: ui2 handles msg/dialog/pager. We replace ui2.cmd entirely
-- with our own cmdline handlers that render into ui2's cmd floating window
-- without ever changing cmdheight. This matches Noice's behavior:
-- cmdheight stays 0, the cmdline floats over the statusline row, and
-- Neovim's native incsearch highlighting works unhindered.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    local ui2 = require("vim._core.ui2")
    local messages = require("vim._core.ui2.messages")

    local hl_ns = vim.api.nvim_create_namespace("ui2_cmdline_hl")
    local search_ns = vim.api.nvim_create_namespace("ui2_search_count")

    -- Catppuccin-themed highlights.
    local function setup_highlights()
      local p = utils.get_palette()
      local set = vim.api.nvim_set_hl
      set(0, "Ui2Cmdline", { fg = p.text, bg = p.mantle })
      set(0, "Ui2CmdlineIcon", { fg = p.sky, bg = p.mantle, bold = true })
      set(0, "Ui2CmdlineIconSearch", { fg = p.yellow, bg = p.mantle, bold = true })
      set(0, "Ui2CmdlineIconLua", { fg = p.blue, bg = p.mantle, bold = true })
      set(0, "Ui2SearchCount", { fg = p.lavender, bg = p.surface0 })
      set(0, "Ui2Mini", { fg = p.subtext0, bg = p.base })
    end
    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = setup_highlights,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cmd",
      callback = function()
        vim.wo.winhighlight = "Normal:Ui2Cmdline,Search:,CurSearch:,IncSearch:"
      end,
    })

    ui2.enable({
      msg = {
        target = "msg",
      },
    })

    -- Reposition the ephemeral msg window to top-left (ui2 defaults to
    -- bottom-right with anchor=SE). Wrapping set_pos catches both initial
    -- placement and updates after message add/remove.
    local orig_set_pos = messages.set_pos
    messages.set_pos = function(tgt)
      orig_set_pos(tgt)
      if tgt == "msg" or tgt == nil then
        local win = ui2.wins.msg
        if win and vim.api.nvim_win_is_valid(win) then
          local cfg = vim.api.nvim_win_get_config(win)
          if not cfg.hide then
            pcall(vim.api.nvim_win_set_config, win, {
              relative = "editor",
              anchor = "NE",
              row = 1,
              col = vim.o.columns,
            })
          end
        end
      end
    end

    -- ==== Icon configuration =========================================

    local CMD_ICON = "\u{0020}\u{E6AE}\u{0020}"
    local SEARCH_ICON = "\u{0020}\u{EAF3}\u{0020}"
    local RSEARCH_ICON = "\u{0020}\u{EAF4}\u{0020}"
    local LUA_ICON = "\u{0020}\u{E620}\u{0020}"

    local icon_map = {
      [":"] = { icon = CMD_ICON, hl = "Ui2CmdlineIcon" },
      ["/"] = { icon = SEARCH_ICON, hl = "Ui2CmdlineIconSearch" },
      ["?"] = { icon = RSEARCH_ICON, hl = "Ui2CmdlineIconSearch" },
      ["="] = { icon = LUA_ICON, hl = "Ui2CmdlineIconLua" },
    }

    -- ==== Mini view (bottom-right, faded, no border) =================

    local mini_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[mini_buf].buftype = "nofile"
    local mini_win = nil
    -- Single long-lived timer reused via stop()/start(). The earlier
    -- implementation re-created a timer per show via vim.defer_fn, which
    -- leaked the libuv handle on every re-arm because vim.defer_fn only
    -- closes the timer on callback fire, not when it's :stop()ed early.
    local mini_timer = assert(vim.uv.new_timer())

    local function hide_mini()
      if mini_win and vim.api.nvim_win_is_valid(mini_win) then
        pcall(vim.api.nvim_win_set_config, mini_win, { hide = true })
      end
    end

    local function show_mini(text, timeout)
      timeout = timeout or 3000
      local lines = {}
      for _, line in ipairs(vim.split(vim.trim(text), "\n", { plain = true })) do
        if line ~= "" then lines[#lines + 1] = " " .. line .. " " end
      end
      if #lines == 0 then return end
      vim.api.nvim_buf_set_lines(mini_buf, 0, -1, false, lines)

      local width = 0
      for _, line in ipairs(lines) do
        width = math.max(width, vim.api.nvim_strwidth(line))
      end
      width = math.min(width, math.floor(vim.o.columns * 0.6))
      local height = #lines
      local row = vim.o.lines - height - 1
      local col = vim.o.columns - width - 1

      if mini_win and vim.api.nvim_win_is_valid(mini_win) then
        pcall(vim.api.nvim_win_set_config, mini_win, {
          hide = false,
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
        })
      else
        mini_win = vim.api.nvim_open_win(mini_buf, false, {
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
          style = "minimal",
          border = "none",
          focusable = false,
          zindex = 60,
          noautocmd = true,
        })
        vim.wo[mini_win].winhighlight = "Normal:Ui2Mini"
        vim.wo[mini_win].wrap = false
      end

      mini_timer:stop()
      mini_timer:start(timeout, 0, vim.schedule_wrap(hide_mini))
    end

    -- ==== Search count (eol virt_text on editor cursor line) =========

    local search_extmark_id = nil
    local search_extmark_buf = nil
    local search_count_text = nil

    local function clear_search_count()
      if search_extmark_id and search_extmark_buf and vim.api.nvim_buf_is_valid(search_extmark_buf) then
        pcall(vim.api.nvim_buf_del_extmark, search_extmark_buf, search_ns, search_extmark_id)
      end
      search_extmark_id = nil
      search_extmark_buf = nil
      search_count_text = nil
    end

    local function place_search_count(text)
      if text then search_count_text = text end
      if not search_count_text or search_count_text == "" then return end
      local current = search_count_text
      local buf = vim.api.nvim_get_current_buf()
      local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, 0)
      if not ok_cursor or not cursor then return end
      if search_extmark_buf and search_extmark_buf ~= buf then
        clear_search_count()
        search_count_text = current
      end
      search_extmark_buf = buf
      local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, search_ns, cursor[1] - 1, 0, {
        id = search_extmark_id,
        virt_text = { { " " .. vim.trim(current), "Ui2SearchCount" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
      if ok then search_extmark_id = id end
    end

    -- ==== Custom cmdline handlers ====================================
    -- These replace ui2.cmd entirely. They render the cmdline into ui2's
    -- existing cmd floating window but NEVER touch cmdheight, matching
    -- Noice's architecture. The dispatcher (ui2.lua:ui_callback) looks
    -- up handlers via ui2.cmd[event], so swapping the table is the
    -- clean hand-off point.

    local cmd = {
      srow = 0,
      erow = 0,
      level = 0,
      prompt = false,
      indent = 0,
      wmnumode = 0,
      expand = 0,
      dialog = false,
    }

    local cmdbuff = ""
    local promptlen = 0

    local function render(content, prompt_str, hl_id)
      local lines = {}
      for line in (prompt_str .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = vim.fn.strtrans(line)
      end
      cmdbuff = ""
      promptlen = #lines[#lines]
      cmd.erow = cmd.srow + #lines - 1
      for _, chunk in ipairs(content) do
        cmdbuff = cmdbuff .. chunk[2]
      end
      lines[#lines] = lines[#lines] .. vim.fn.strtrans(cmdbuff) .. " "
      pcall(vim.api.nvim_buf_set_lines, ui2.bufs.cmd, cmd.srow, -1, false, lines)

      if promptlen > 0 and hl_id and hl_id > 0 then
        pcall(vim.api.nvim_buf_set_extmark, ui2.bufs.cmd, ui2.ns, cmd.srow, 0, {
          invalidate = true,
          undo_restore = false,
          end_col = promptlen,
          end_line = cmd.erow,
          hl_group = hl_id,
        })
      end
    end

    -- ==== Centered dialog for confirm/input prompts ====================

    local dialog_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[dialog_buf].buftype = "nofile"
    local dialog_win = nil
    local dialog_active = false

    local function show_dialog(lines)
      local width = 0
      for _, line in ipairs(lines) do
        width = math.max(width, vim.api.nvim_strwidth(line))
      end
      width = math.max(width + 4, 40)
      width = math.min(width, math.floor(vim.o.columns * 0.8))
      local height = #lines
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      if dialog_win and vim.api.nvim_win_is_valid(dialog_win) then
        pcall(vim.api.nvim_win_set_config, dialog_win, {
          hide = false,
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
        })
      else
        dialog_win = vim.api.nvim_open_win(dialog_buf, false, {
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
          style = "minimal",
          border = "rounded",
          focusable = false,
          zindex = 250,
          noautocmd = true,
        })
        vim.wo[dialog_win].winhighlight = "Normal:Ui2Cmdline,FloatBorder:FloatBorder"
        vim.wo[dialog_win].wrap = true
      end
      -- Set buffer lines AFTER opening/unhiding the window. Setting them
      -- first inside a UI handler (our cmdline_show) leaves the window's
      -- dirty region out of the post-handler redraw that ui2 targets at
      -- wins.cmd — the box borders paint but the text stays invisible
      -- until the next unrelated redraw (e.g. a mouse click).
      vim.api.nvim_buf_set_lines(dialog_buf, 0, -1, false, lines)
      dialog_active = true
    end

    local function hide_dialog()
      if dialog_win and vim.api.nvim_win_is_valid(dialog_win) then
        pcall(vim.api.nvim_win_set_config, dialog_win, { hide = true })
      end
      dialog_active = false
    end

    -- Capture raw msg_show events BEFORE ui2's callback schedules them.
    -- ui2 defers msg_show in fast events (vim.schedule_wrap), so our
    -- wrapper on messages.msg_show runs too late for confirm dialogs.
    -- This parallel ui_attach runs synchronously and just buffers the
    -- text — it does NOT consume the event (returns nil, not true).
    local dialog_msg_queue = {}
    -- Long-lived timer (see comment on mini_timer above for the leak this
    -- avoids vs. per-call vim.defer_fn).
    local dialog_msg_timer = assert(vim.uv.new_timer())
    local raw_msg_ns = vim.api.nvim_create_namespace("ui2_raw_msg")

    -- Declared up here so the closure below and messages.msg_show later
    -- both capture the same upvalue (Lua's local scope only starts after
    -- the `local` statement — referencing it from a closure defined
    -- earlier would bind to a global instead).
    local echoing_history = false

    vim.ui_attach(raw_msg_ns, { ext_messages = true }, function(event, ...)
      if event == "msg_show" then
        local kind, content = ...
        if kind ~= "search_count" and not echoing_history then
          local parts = {}
          for _, chunk in ipairs(content or {}) do
            parts[#parts + 1] = chunk[2] or ""
          end
          local text = table.concat(parts)
          if text ~= "" and text ~= "\n" then
            dialog_msg_queue[#dialog_msg_queue + 1] = text
            dialog_msg_timer:stop()
            dialog_msg_timer:start(500, 0, vim.schedule_wrap(function()
              dialog_msg_queue = {}
            end))
          end
        end
      end
    end)

    local function drain_dialog_msgs()
      local msgs = dialog_msg_queue
      dialog_msg_queue = {}
      dialog_msg_timer:stop()
      return msgs
    end

    local function show_cmd_window()
      local win = ui2.wins.cmd
      if not win or not vim.api.nvim_win_is_valid(win) then return end
      local line_count = math.max(vim.api.nvim_buf_line_count(ui2.bufs.cmd), 1)
      local cmd_row = vim.o.lines - line_count
      pcall(vim.api.nvim_win_set_config, win, {
        hide = false,
        relative = "editor",
        row = cmd_row,
        col = 0,
        width = vim.o.columns,
        height = line_count,
      })
      -- Tell blink.cmp (and other plugins) where the cmdline float is.
      -- blink.cmp reads this in its default cmdline_position() function.
      vim.g.ui_cmdline_pos = { cmd_row + 1, 0 }
    end

    local function hide_cmd_window()
      vim.g.ui_cmdline_pos = nil
      if ui2.wins.cmd and vim.api.nvim_win_is_valid(ui2.wins.cmd) then
        pcall(vim.api.nvim_win_set_config, ui2.wins.cmd, { hide = true })
      end
    end

    function cmd.cmdline_show(content, pos, firstc, prompt, indent, level, hl_id)
      cmd.level = level
      cmd.indent = indent
      cmd.prompt = #prompt > 0

      -- Confirm / input prompts (firstc="" with non-empty prompt) →
      -- centered dialog instead of the statusline bar. Pull in any
      -- message that arrived just before (e.g. the warning text).
      if cmd.prompt and (firstc == "" or icon_map[firstc] == nil) then
        local typed = ""
        for _, chunk in ipairs(content) do
          typed = typed .. chunk[2]
        end
        local lines = {}
        local msgs = drain_dialog_msgs()
        if #msgs > 0 then
          hide_mini()
          if ui2.wins.msg and vim.api.nvim_win_is_valid(ui2.wins.msg) then
            pcall(vim.api.nvim_win_set_config, ui2.wins.msg, { hide = true })
          end
          for _, msg in ipairs(msgs) do
            for line in msg:gmatch("[^\n]+") do
              lines[#lines + 1] = "  " .. line .. "  "
            end
          end
          lines[#lines + 1] = ""
        end
        for line in prompt:gmatch("[^\n]+") do
          lines[#lines + 1] = "  " .. line .. "  "
        end
        if typed ~= "" then
          lines[#lines + 1] = ""
          lines[#lines + 1] = "  > " .. typed .. "  "
        end
        show_dialog(lines)
        hide_cmd_window()
        return
      end

      dialog_msg_queue = {}

      local entry = icon_map[firstc] or { icon = firstc, hl = "Ui2CmdlineIcon" }
      local icon, hl = entry.icon, entry.hl

      if firstc == ":" then
        local text = ""
        for _, chunk in ipairs(content) do
          text = text .. chunk[2]
        end
        if text:match("^lua[%s=]") or text == "lua" or text:match("^=") then
          icon = LUA_ICON
          hl = "Ui2CmdlineIconLua"
        end
      end

      render(content, ("%s%s%s"):format(icon, prompt, (" "):rep(indent)), hl_id)

      pcall(vim.api.nvim_buf_set_extmark, ui2.bufs.cmd, hl_ns, cmd.srow, 0, {
        end_col = #icon,
        hl_group = hl,
        invalidate = true,
        undo_restore = false,
        priority = 200,
      })

      show_cmd_window()
      cmd.cmdline_pos(pos)

      if firstc == "/" or firstc == "?" then
        place_search_count()
      end
    end

    function cmd.cmdline_pos(pos)
      if not ui2.wins.cmd or not vim.api.nvim_win_is_valid(ui2.wins.cmd) then return end
      local col = #vim.fn.strtrans(cmdbuff:sub(1, pos))
      pcall(vim.api.nvim_win_set_cursor, ui2.wins.cmd, {
        cmd.erow + 1,
        promptlen + col,
      })
    end

    function cmd.cmdline_special_char(c, shift)
      pcall(vim.api.nvim_win_call, ui2.wins.cmd, function()
        vim.api.nvim_put({ c }, shift and "" or "c", false, false)
      end)
    end

    function cmd.cmdline_hide(level, abort)
      if cmd.srow > 0 or level > (vim.fn.getcmdwintype() == "" and 1 or 2) then
        return
      end
      vim.fn.clearmatches(ui2.wins.cmd)
      pcall(vim.api.nvim_win_set_cursor, ui2.wins.cmd, { 1, 0 })
      if cmd.prompt or abort then
        pcall(vim.api.nvim_buf_set_lines, ui2.bufs.cmd, 0, -1, false, {})
      end
      cmd.prompt = false
      cmd.level = 0
      hide_dialog()
      hide_cmd_window()
    end

    function cmd.cmdline_block_show(lines)
      for _, content in ipairs(lines) do
        render(content, ":", 0)
        cmd.srow = cmd.srow + 1
      end
      show_cmd_window()
    end

    function cmd.cmdline_block_append(line)
      render(line, ":", 0)
      cmd.srow = cmd.srow + 1
      show_cmd_window()
    end

    function cmd.cmdline_block_hide()
      cmd.srow = 0
      cmd.cmdline_hide(cmd.level, true)
    end

    -- Hand off: replace ui2's cmd module with ours.
    ui2.cmd = cmd

    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        if ui2.wins.cmd and vim.api.nvim_win_is_valid(ui2.wins.cmd)
            and not vim.api.nvim_win_get_config(ui2.wins.cmd).hide then
          show_cmd_window()
        end
      end,
    })

    -- ==== LSP progress in the mini view ===============================

    local spinner_frames = {
      "\u{280B}", "\u{2819}", "\u{2839}", "\u{2838}", "\u{283C}",
      "\u{2834}", "\u{2826}", "\u{2827}", "\u{2807}", "\u{280F}",
    }
    local lsp_spinner_idx = 0

    vim.api.nvim_create_autocmd("LspProgress", {
      callback = function(ev)
        local val = ev.data and ev.data.params and ev.data.params.value
        if not val then return end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local name = client and client.name or "LSP"
        if val.kind == "end" then
          show_mini(name .. ": " .. (val.title or "done") .. " \u{2713}", 2000)
          return
        end
        lsp_spinner_idx = (lsp_spinner_idx % #spinner_frames) + 1
        local parts = { spinner_frames[lsp_spinner_idx], name }
        if val.title then parts[#parts + 1] = val.title end
        if val.message then parts[#parts + 1] = val.message end
        if val.percentage then parts[#parts + 1] = "(" .. val.percentage .. "%)" end
        show_mini(table.concat(parts, " "), 5000)
      end,
    })

    -- ==== Message routing ============================================

    local error_kinds = { emsg = true, lua_error = true, rpc_error = true, echoerr = true }

    local orig_msg_show = messages.msg_show
    messages.msg_show = function(kind, content, replace_last, history, append, id, trigger)
      if echoing_history then return end

      if kind == "search_count" then
        local full_text = ""
        for _, chunk in ipairs(content or {}) do
          full_text = full_text .. (chunk[2] or "")
        end
        place_search_count(full_text:match("%[.+%]"))
        return
      end

      local text_parts = {}
      for _, chunk in ipairs(content or {}) do
        text_parts[#text_parts + 1] = chunk[2] or ""
      end
      local text = table.concat(text_parts)

      -- Errors → top-right msg window. Everything else → mini view.
      if error_kinds[kind] then
        return orig_msg_show(kind, content, replace_last, history, append, id, trigger)
      end
      if text ~= "" and text ~= "\n" then
        -- Defer mini: if a confirm/input dialog opens within the same
        -- redraw batch, dialog_active will be true and we skip mini.
        local t = text
        vim.schedule(function()
          if not dialog_active then show_mini(t) end
        end)
        if not history then
          echoing_history = true
          pcall(vim.api.nvim_echo, { { text } }, true, {})
          echoing_history = false
        end
      end
    end

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      callback = clear_search_count,
    })

    local msg_history_ns = vim.api.nvim_create_namespace("msg_history_hl")

    local notif_level_hl = {
      error = "ErrorMsg",
      warn = "WarningMsg",
      debug = "Comment",
      trace = "Comment",
    }

    messages.msg_history_show = function(entries)
      local lines = {}
      local marks = {}

      local function add_line(text, hl)
        lines[#lines + 1] = text
        if hl and text ~= "" then
          marks[#marks + 1] = { #lines - 1, 0, #text, hl }
        end
      end

      -- Neovim message history (errors, echomsg, etc.)
      for _, entry in ipairs(entries or {}) do
        if lines[#lines] and lines[#lines] ~= "" then add_line("") end
        local content = entry[2]
        for _, chunk in ipairs(content) do
          local text = chunk[2] or ""
          local hl = chunk[3]
          local text_parts = vim.split(text, "\n", { plain = true })
          for pi, part in ipairs(text_parts) do
            if pi > 1 then lines[#lines + 1] = "" end
            local cr_segs = vim.split(part, "\r", { plain = true })
            part = cr_segs[#cr_segs]
            if #cr_segs > 1 then
              lines[#lines] = ""
              marks = vim.tbl_filter(function(m) return m[1] ~= #lines - 1 end, marks)
            end
            if #lines == 0 then lines[1] = "" end
            local lnum = #lines - 1
            local col = #lines[#lines]
            lines[#lines] = lines[#lines] .. part
            if hl and hl > 0 and #part > 0 then
              marks[#marks + 1] = { lnum, col, col + #part, hl }
            end
          end
        end
      end

      -- Snacks notification history (vim.notify messages)
      local ok, notifs = pcall(function() return Snacks.notifier.get_history() end)
      if ok and notifs and #notifs > 0 then
        if #lines > 0 then add_line("") end
        for _, notif in ipairs(notifs) do
          if lines[#lines] and lines[#lines] ~= "" then add_line("") end
          local hl = notif_level_hl[notif.level] or "Normal"
          local prefix = notif.title and notif.title ~= "" and (notif.title .. ": ") or ""
          for _, line in ipairs(vim.split(notif.msg or "", "\n", { plain = true })) do
            if line ~= "" then
              add_line(prefix .. line, hl)
              prefix = ""
            end
          end
        end
      end

      if #lines == 0 or (#lines == 1 and lines[1] == "") then return end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].buflisted = false
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      for _, m in ipairs(marks) do
        pcall(vim.api.nvim_buf_set_extmark, buf, msg_history_ns, m[1], m[2], {
          end_col = m[3],
          hl_group = m[4],
        })
      end
      vim.bo[buf].modifiable = false

      vim.cmd("botright split")
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_win_set_height(0, math.min(#lines, math.floor(vim.o.lines * 0.4)))
      vim.cmd("normal! G")
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
    end

    utils.wk_add({
      { "<leader>nh", "<cmd>messages<CR>",      desc = "Message history",   mode = "n" },
      { "<leader>nl", "<cmd>normal! g<lt><CR>", desc = "Show last message", mode = "n" },
    })
  end,
})
