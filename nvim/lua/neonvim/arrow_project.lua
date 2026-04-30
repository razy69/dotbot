---@brief Project-wide view of arrow.nvim marks.
--- Arrow stores its general (file) marks in a single per-project cache
--- file and its buffer (line) marks in one cache file per source file.
--- Neither is organised around "all marks in this project" — which is
--- what the statusline, dashboard, and project-wide picker need. This
--- module maintains a per-project side-car index with that shape, kept
--- in sync via arrow's ArrowUpdate / ArrowMarkUpdate autocmds.
---
--- Index layout: one JSON file per project root at
---   stdpath("data")/arrow_project/<base64(project_root)>.json
--- containing `{ files = [...], line_marks = { [abs_path] = [{line,col}, ...] } }`.
---
--- Bootstrap: on setup() we load the side-car (cheap), then — if it's
--- empty — schedule a one-time seed from arrow's on-disk cache by
--- walking `git ls-files` and stat'ing expected cache filenames. After
--- that, the runtime listeners keep us current. `:ArrowProjectRefresh`
--- re-seeds on demand for edits made outside this session.

local M         = {}

local STATE_DIR = vim.fs.joinpath(vim.fn.stdpath("data"), "arrow_project")

-- Arrow stores file marks as relative paths sometimes prefixed with `./`.
-- Trim it once here so equality and joinpath aren't fooled by the prefix.
-- Wrapped in parens so only the string (not the gsub count) is returned.
local function strip_dot_slash(p)
  return (p:gsub("^%./", ""))
end

---@class arrow_project.Mark
---@field line integer 1-based row
---@field col integer 0-based column

---@class arrow_project.State
---@field files string[] arrow general-mode marks (relative paths under project_root, as arrow stores them)
---@field line_marks table<string, arrow_project.Mark[]> abs_path -> bookmarks

---@type string?
local project_root
---@type arrow_project.State
local state       = { files = {}, line_marks = {} }
local initialized = false
---@type uv.uv_timer_t?
local save_timer

-- === Paths =============================================================

local function get_root()
  local ok, snacks_git = pcall(require, "snacks.git")
  if ok then
    local r = snacks_git.get_root()
    if r then return r end
  end
  return vim.uv.cwd() or vim.fn.getcwd()
end

local function state_file_path()
  if not project_root then return nil end
  return vim.fs.joinpath(STATE_DIR, vim.base64.encode(project_root) .. ".json")
end

-- === Persistence =======================================================

local function load_state()
  local path = state_file_path()
  if not path or vim.fn.filereadable(path) == 0 then return end
  local ok, content = pcall(vim.fn.readfile, path)
  if not ok or not content or #content == 0 then return end
  local ok2, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
  if ok2 and type(decoded) == "table" then
    state.files = decoded.files or {}
    state.line_marks = decoded.line_marks or {}
  end
end

local function save_state_now()
  local path = state_file_path()
  if not path then return end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local ok, encoded = pcall(vim.json.encode, state)
  if not ok then return end
  pcall(vim.fn.writefile, { encoded }, path)
end

-- Debounce persistence: rapid-fire events (deleting several bookmarks in
-- sequence, arrow's redraw-then-sync cycle) collapse into one disk write.
local function schedule_save()
  if save_timer then
    pcall(function() save_timer:stop() end)
    pcall(function() save_timer:close() end)
    save_timer = nil
  end
  save_timer = assert(vim.uv.new_timer())
  save_timer:start(200, 0, vim.schedule_wrap(function()
    save_state_now()
    if save_timer then
      pcall(function() save_timer:close() end)
      save_timer = nil
    end
  end))
end

-- === Runtime sync ======================================================

local function refresh_files()
  state.files = vim.deepcopy(vim.g.arrow_filenames or {})
  schedule_save()
end

--- Re-read the in-memory line marks for `bufnr` from arrow's
--- buffer_persist and mirror them into our index. Called from
--- ArrowMarkUpdate — arrow fires the event after its own bookmark table
--- for the current buffer has been mutated, so we just copy.
local function refresh_line_marks_for_buffer(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return end
  if project_root and not (path == project_root or vim.startswith(path, project_root .. "/")) then
    return
  end
  local ok, bp = pcall(require, "arrow.buffer_persist")
  if not ok then return end
  local bookmarks = bp.get_bookmarks_by(bufnr)
  if bookmarks and #bookmarks > 0 then
    -- Strip transient ext_id — not meaningful across sessions.
    local clean = {}
    for _, m in ipairs(bookmarks) do
      clean[#clean + 1] = { line = m.line, col = m.col or 0 }
    end
    state.line_marks[path] = clean
  else
    state.line_marks[path] = nil
  end
  schedule_save()
end

-- === Seed from arrow's on-disk cache ===================================

--- Compute arrow's save_path from its config, falling back to its
--- documented default if arrow hasn't been loaded yet.
local function arrow_save_path()
  local ok, cfg = pcall(require, "arrow.config")
  if ok then
    local fn = cfg.getState("save_path")
    if fn then return (fn():gsub("/$", "")) end
  end
  return (vim.fn.stdpath("cache") .. "/arrow"):gsub("/$", "")
end

--- Enumerate project files via `git ls-files`. Returns an empty table
--- outside a git repo — runtime ArrowMarkUpdate still keeps the index
--- current for whatever files the user marks during the session.
--- Bounded with a 5s timeout so that a hung git (network filesystem,
--- corrupted repo) can't stall the deferred seed indefinitely.
local function project_tracked_files()
  if not project_root then return {} end
  local result = vim.system(
    { "git", "-C", project_root, "ls-files" },
    { text = true }
  ):wait(5000)
  if result.code ~= 0 or not result.stdout then return {} end
  local files = {}
  for rel in result.stdout:gmatch("[^\r\n]+") do
    if rel ~= "" then
      files[#files + 1] = vim.fs.joinpath(project_root, rel)
    end
  end
  return files
end

local function seed_line_marks()
  local ok_util, arrow_util = pcall(require, "arrow.utils")
  local ok_json, arrow_json = pcall(require, "arrow.json")
  if not (ok_util and ok_json) then return end
  local save_path = arrow_save_path()
  if vim.fn.isdirectory(save_path) == 0 then return end

  local new_marks = {}
  for _, abs_path in ipairs(project_tracked_files()) do
    local cache_file = save_path .. "/" .. arrow_util.normalize_path_to_filename(abs_path)
    if vim.fn.filereadable(cache_file) == 1 then
      local ok, content = pcall(vim.fn.readfile, cache_file)
      if ok and content and #content > 0 then
        local ok2, decoded = pcall(arrow_json.decode, table.concat(content, "\n"))
        if ok2 and type(decoded) == "table" and #decoded > 0 then
          local clean = {}
          for _, m in ipairs(decoded) do
            if type(m) == "table" and m.line then
              clean[#clean + 1] = { line = m.line, col = m.col or 0 }
            end
          end
          if #clean > 0 then
            new_marks[abs_path] = clean
          end
        end
      end
    end
  end
  state.line_marks = new_marks
end

-- === Public API ========================================================

function M.get_root()
  return project_root
end

---@return string[]
function M.get_files()
  return state.files or {}
end

---@return table<string, arrow_project.Mark[]>
function M.get_line_marks()
  return state.line_marks or {}
end

---@return {files:integer, line_marks:integer, files_with_lines:integer}
function M.count()
  local files_with, marks = 0, 0
  for _, b in pairs(state.line_marks or {}) do
    if #b > 0 then
      files_with = files_with + 1
      marks = marks + #b
    end
  end
  return { files = #(state.files or {}), line_marks = marks, files_with_lines = files_with }
end

--- Returns "file" / "lines" / "both" / nil for the given path.
--- Accepts absolute or project-relative paths — arrow stores general-mode
--- marks as relative strings (in cwd save_key mode) and buffer marks are
--- keyed by absolute path, so callers may hit either.
---@param path string
---@return "file"|"lines"|"both"|nil
function M.has_mark(path)
  local abs = path
  local rel = path
  if project_root then
    if vim.startswith(path, project_root .. "/") then
      rel = path:sub(#project_root + 2)
    elseif not vim.startswith(path, "/") then
      abs = vim.fs.joinpath(project_root, path)
    end
  end

  local has_file = false
  for _, f in ipairs(state.files or {}) do
    local fn = strip_dot_slash(f)
    if fn == rel or fn == abs or fn == path then
      has_file = true
      break
    end
  end
  local lines = (state.line_marks or {})[abs]
  local has_lines = lines and #lines > 0

  if has_file and has_lines then return "both" end
  if has_file then return "file" end
  if has_lines then return "lines" end
  return nil
end

--- Re-seed the index from arrow's on-disk cache. Use after editing
--- arrow's files directly or when the index looks stale.
function M.refresh()
  refresh_files()
  seed_line_marks()
  schedule_save()
end

--- Resolve a project-relative file mark to its absolute path.
---@param rel string
---@return string
local function abs_from_rel(rel)
  local clean = strip_dot_slash(rel)
  if vim.startswith(clean, "/") or not project_root then
    return clean
  end
  return vim.fs.joinpath(project_root, clean)
end

--- Show both kinds by default. Toggles are persistent across re-opens
--- within the session so the user's last filter sticks.
local picker_show = { files = true, lines = true }

--- Build the flat item list given current toggles. File marks render
--- with no `pos` (snacks shows them without a line number); line marks
--- render with `pos = {line, col}` so the built-in formatter appends
--- `:L:C` after the filename.
local function build_picker_items()
  local items = {}
  local root = project_root or ""

  if picker_show.files then
    for _, rel in ipairs(state.files or {}) do
      local abs = abs_from_rel(rel)
      items[#items + 1] = {
        file = abs,
        text = rel,
        arrow_kind = "file",
      }
    end
  end

  if picker_show.lines then
    local paths = vim.tbl_keys(state.line_marks or {})
    table.sort(paths)
    for _, path in ipairs(paths) do
      local rel = (root ~= "" and vim.startswith(path, root .. "/"))
          and path:sub(#root + 2)
          or vim.fn.fnamemodify(path, ":~:.")
      for _, m in ipairs(state.line_marks[path]) do
        items[#items + 1] = {
          file = path,
          pos = { m.line, m.col or 0 },
          text = string.format("%s:%d", rel, m.line),
          arrow_kind = "line",
        }
      end
    end
  end

  return items
end

local function picker_title()
  local bits = {}
  if picker_show.files then bits[#bits + 1] = "files" end
  if picker_show.lines then bits[#bits + 1] = "lines" end
  if #bits == 0 then bits[1] = "hidden" end
  return "Arrow Project Marks [" .. table.concat(bits, "+") .. "] · ctrl+h for help"
end

--- Open a snacks.picker listing every arrow mark in the project.
--- Files and line marks are mixed; <C-f>/<C-l> toggle visibility of
--- each kind so the user can focus on one at a time. <C-x> triggers
--- a re-seed from arrow's on-disk cache. Press `ctrl+h` for the built-in
--- help panel, which lists every bound key along with its desc.
function M.pick()
  if vim.tbl_isempty(state.files or {}) and vim.tbl_isempty(state.line_marks or {}) then
    vim.notify("arrow_project: no marks in this project", vim.log.levels.INFO)
    return
  end

  require("snacks").picker({
    title = picker_title(),
    finder = function()
      local items = build_picker_items()
      return function(cb)
        for _, it in ipairs(items) do cb(it) end
      end
    end,
    format = "file",
    preview = "file",
    confirm = function(picker, item)
      picker:close()
      if item and item.file then
        vim.cmd.edit(vim.fn.fnameescape(item.file))
        if item.pos then
          pcall(vim.api.nvim_win_set_cursor, 0, { item.pos[1], item.pos[2] or 0 })
          pcall(function() vim.cmd("normal! zz") end)
        end
      end
    end,
    actions = {
      toggle_files = function(picker)
        picker_show.files = not picker_show.files
        picker.title = picker_title()
        picker:find({ refresh = true })
      end,
      toggle_lines = function(picker)
        picker_show.lines = not picker_show.lines
        picker.title = picker_title()
        picker:find({ refresh = true })
      end,
      refresh_index = function(picker)
        M.refresh()
        picker:find({ refresh = true })
      end,
    },
    win = {
      -- Keys repeated on input+list so they work in either pane. Descs are
      -- what snacks' `ctrl+h` help panel (toggle_help_input / toggle_help_list)
      -- renders next to each binding, so keep them concise.
      input = {
        keys = {
          ["<c-f>"] = { "toggle_files", mode = { "n", "i" }, desc = "Toggle file marks" },
          ["<c-l>"] = { "toggle_lines", mode = { "n", "i" }, desc = "Toggle line marks" },
          ["<c-x>"] = { "refresh_index", mode = { "n", "i" }, desc = "Refresh arrow index" },
          ["<c-h>"] = { "toggle_help_input", mode = { "n", "i" }, desc = "Show help" },
        },
      },
      list = {
        keys = {
          ["<c-f>"] = { "toggle_files", desc = "Toggle file marks" },
          ["<c-l>"] = { "toggle_lines", desc = "Toggle line marks" },
          ["<c-x>"] = { "refresh_index", desc = "Refresh arrow index" },
          ["<c-h>"] = { "toggle_help_list", desc = "Show help" },
        },
      },
    },
  })
end

--- Items for the snacks dashboard section. Up to `opts.limit` general-mode
--- files, then a trailer entry for remaining line marks if present.
---@param opts? {limit?:integer}
function M.dashboard_items(opts)
  opts = opts or {}
  local limit = opts.limit or 5
  local items = {}
  local files = state.files or {}
  local shown = math.min(#files, limit)

  for i = 1, shown do
    local rel = files[i]
    local clean_rel = strip_dot_slash(rel)
    local abs = (project_root and not vim.startswith(rel, "/"))
        and vim.fs.joinpath(project_root, clean_rel)
        or rel
    items[#items + 1] = {
      file = abs,
      icon = "file",
      action = ":edit " .. vim.fn.fnameescape(abs),
      autokey = true,
    }
  end

  local counts = M.count()
  if counts.line_marks > 0 then
    items[#items + 1] = {
      icon = " ",
      desc = string.format("%d line marks in %d files", counts.line_marks, counts.files_with_lines),
      key = "L",
      action = function() M.pick() end,
    }
  end

  return items
end

function M.setup()
  if initialized then return end
  initialized = true

  project_root = get_root()
  vim.fn.mkdir(STATE_DIR, "p")
  load_state()

  local aug = require("utils").augroup("ArrowProject")

  -- File marks: arrow.persist writes vim.g.arrow_filenames before firing.
  vim.api.nvim_create_autocmd("User", {
    group = aug,
    pattern = "ArrowUpdate",
    callback = refresh_files,
  })

  -- Line marks for the current buffer. arrow.buffer_persist fires this
  -- from save/remove/clear/update/load; we just mirror the current
  -- in-memory bookmarks for the active buffer.
  vim.api.nvim_create_autocmd("User", {
    group = aug,
    pattern = "ArrowMarkUpdate",
    callback = function()
      refresh_line_marks_for_buffer(vim.api.nvim_get_current_buf())
    end,
  })

  -- Pull the current general-mode list from arrow (it has already loaded
  -- its cache file by the time our setup runs). Seed line marks from
  -- arrow's disk cache only on first use — side-car persistence covers
  -- subsequent starts.
  refresh_files()
  if vim.tbl_isempty(state.line_marks) then
    vim.schedule(function()
      seed_line_marks()
      schedule_save()
      vim.schedule(function()
        vim.cmd("redrawstatus")
        pcall(function() require("snacks").dashboard.update() end)
      end)
    end)
  end

  vim.api.nvim_create_user_command("ArrowProjectRefresh", function()
    M.refresh()
    vim.notify("arrow_project: re-seeded from arrow cache", vim.log.levels.INFO)
  end, { desc = "Re-seed arrow_project index from arrow's on-disk cache" })
end

return M
