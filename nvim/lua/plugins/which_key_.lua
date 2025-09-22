--[[
  File: which_key_.lua
  Description: Helps you remember your Neovim keymaps, by showing available keybindings in a popup as you type.
  Link: https://github.com/folke/which-key.nvim
]]

-- Modes
--
--  n	Normal
--  v	Visual and Select
--  s	Select
--  x	Visual
--  o	Operator-pending
--  !	Insert and Command-line
--  i	Insert
--  l	":lmap" mappings for Insert, Command-line and Lang-Arg
--  c	Command-line
--  t	Terminal-Job

local utils = require("utilities.module")
local win_utils = require("utilities.window")
local wk = require("which-key")

-- Disable Exising Bindings
vim.api.nvim_set_keymap("i", "<C-n>", "<Nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-p>", "<Nop>", { noremap = true })

-- Special mapping
vim.keymap.set(
  "n",
  "dd",
  function()
    if vim.api.nvim_get_current_line():match("^%s*$") then
      return '\"_dd'
    else
      return "dd"
    end
  end,
  { noremap = true, expr = true, desc = "Smart dd, do not override history if empty line" }
)

wk.setup({
  win = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    wo = {
      winblend = 0,
    }
  },
  plugins = {
    marks = true,       -- shows a list of your marks on ' and `
    registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
  }
})

-- KEYMAP
wk.add({

  -- Which-Key
  { "<leader>`",    function() wk.show() end,                  desc = "Show Keymap",                     mode = "n" },

  -- VIM
  { "<leader>w",    "<cmd>w<cr>",                              desc = "Save buffer",                     mode = { "n" } },
  { "<leader>qq",   "<cmd>confirm q<cr>",                      desc = "Quit buffer",                     mode = { "n" } },
  { "<leader>qa",   "<cmd>confirm qall<cr>",                   desc = "Quit all buffers",                mode = { "n" } },
  { "<leader><bs>", "za<cr>",                                  desc = "Fold/Unfold code",                mode = { "n" } },
  { "<leader>bg",   "<cmd>BackgroundToggle<cr>",               desc = "Toggle background light/dark",    mode = { "n" } },
  { "<leader>qf",   "<cmd>copen<cr>",                          desc = "Open quickfix",                   mode = { "n" } },
  { "+",            "<C-a>",                                   desc = "Increment Numbers",               mode = { "n" } },
  { "-",            "<C-x>",                                   desc = "Decrement Numbers",               mode = { "n" } },
  { "+",            "<C-a>gv",                                 desc = "Increment Numbers",               mode = { "v" } },
  { "-",            "<C-x>gv",                                 desc = "Decrement Numbers",               mode = { "v" } },
  { "<leader>/",    ":%s/",                                    desc = "Substitute",                      mode = { "n" } },
  { "<leader>?",    ":%S/",                                    desc = "Substitute (rev)",                mode = { "n" } },
  { "<leader>/",    ":s/",                                     desc = "Substitute",                      mode = { "x" } },
  { "<leader>?",    ":S/",                                     desc = "Substitute (rev)",                mode = { "x" } },
  { "<bs>",         "^",                                       desc = "Go to first non-blank character", mode = { "n", "v" } },
  { "<bs><space>",  "$",                                       desc = "Go to last character",            mode = { "n", "v" } },
  { "<C-S-Left>",   function() win_utils.resize_left(10) end,  mode = { "n" } },
  { "<C-S-Right>",  function() win_utils.resize_right(10) end, mode = { "n" } },
  { "<C-S-Up>",     function() win_utils.resize_up(5) end,     mode = { "n" } },
  { "<C-S-Down>",   function() win_utils.resize_down(5) end,   mode = { "n" } },
})

local persistence = utils.prequire("persistence")
if persistence then
  wk.add({
    { "<leader>qs", function() persistence.select() end,              desc = "Select session to load",             mode = "n" },
    { "<leader>qS", function() persistence.load() end,                desc = "Load session for current directory", mode = "n" },
    { "<leader>ql", function() persistence.load({ last = true }) end, desc = "Load last session",                  mode = "n" },
  })
end

local fzf_lua = utils.prequire("fzf-lua")
if fzf_lua then
  wk.add({
    { "<leader>O",    function() fzf_lua.oldfiles() end,                         desc = "Show recent files",       mode = "n" },
    { "<leader>o",    function() fzf_lua.files() end,                            desc = "Search for a file",       mode = "n" },
    { "<leader>i",    function() fzf_lua.jumps() end,                            desc = "Go to previous location", mode = "n" },
    { "<leader>gr",   function() fzf_lua.live_grep({ multiprocess = true }) end, desc = "Find string in project",  mode = "n" },
    { "<leader>b",    function() fzf_lua.buffers() end,                          desc = "Show all buffers",        mode = "n" },
    { "<leader>todo", "<cmd>TodoFzf<cr>",                                        desc = "Todo things",             mode = "n" },
  })
end

local trouble = utils.prequire("trouble")
if trouble then
  wk.add({
    { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>",   desc = "Diagnostics (Trouble)",        mode = "n" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)", mode = "n" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)",            mode = "n" },
  })
end

local noice = utils.prequire("noice")
if noice then
  wk.add({
    { "<leader>nl", function() noice.cmd("last") end, desc = "Last Noice message",    mode = "n" },
    { "<leader>nh", function() noice.cmd("fzf") end,  desc = "Noice message history", mode = "n" },
  })
end

local flash = utils.prequire("flash")
if flash then
  wk.add({
    { "S",  function() flash.jump() end,              desc = "Flash",             mode = { "n", "x", "o" } },
    { "St", function() flash.treesitter() end,        desc = "Flash Treesitter",  mode = { "n", "x", "o" } },
    { "R",  function() flash.treesitter_search() end, desc = "Treesitter Search", mode = { "o", "x" } },
  })
end

local neotree = utils.prequire("neo-tree.command")
if neotree then
  wk.add({
    { "<leader>e", function() neotree.execute({ toggle = true }) end, desc = "Toggle NeoTree", mode = { "n" } },
  })
end

local dap = utils.prequire("dap")
if dap then
  wk.add({
    { "<leader>db", function() dap.toggle_breakpoint() end,                                    desc = "toggle [d]ebug [b]reakpoint",     mode = { "n" } },
    { "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "[d]ebug [B]reakpoint",            mode = { "n" } },
    { "<leader>dc", function() dap.continue() end,                                             desc = "[d]ebug [c]ontinue (start here)", mode = { "n" } },
    { "<leader>dC", function() dap.run_to_cursor() end,                                        desc = "[d]ebug [C]ursor",                mode = { "n" } },
    { "<leader>dg", function() dap.goto_() end,                                                desc = "[d]ebug [g]o to line",            mode = { "n" } },
    { "<leader>do", function() dap.step_over() end,                                            desc = "[d]ebug step [o]ver",             mode = { "n" } },
    { "<leader>dO", function() dap.step_out() end,                                             desc = "[d]ebug step [O]ut",              mode = { "n" } },
    { "<leader>di", function() dap.step_into() end,                                            desc = "[d]ebug [i]nto",                  mode = { "n" } },
    { "<leader>dj", function() dap.down() end,                                                 desc = "[d]ebug [j]ump down",             mode = { "n" } },
    { "<leader>dk", function() dap.up() end,                                                   desc = "[d]ebug [k]ump up",               mode = { "n" } },
    { "<leader>dl", function() dap.run_last() end,                                             desc = "[d]ebug [l]ast",                  mode = { "n" } },
    { "<leader>dp", function() dap.pause() end,                                                desc = "[d]ebug [p]ause",                 mode = { "n" } },
    { "<leader>dr", function() dap.repl.toggle() end,                                          desc = "[d]ebug [r]epl",                  mode = { "n" } },
    { "<leader>dR", function() dap.clear_breakpoints() end,                                    desc = "[d]ebug [R]emove breakpoints",    mode = { "n" } },
    { "<leader>ds", function() dap.session() end,                                              desc = "[d]ebug [s]ession",               mode = { "n" } },
    { "<leader>dt", function() dap.terminate() end,                                            desc = "[d]ebug [t]erminate",             mode = { "n" } },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end,                          desc = "[d]ebug [w]idgets",               mode = { "n" } },
  })
end

local dapui = utils.prequire("dapui")
if dapui then
  wk.add({
    { "<leader>du", function() dapui.toggle() end, desc = "[d]ap [u]i",   mode = { "n" } },
    { "<leader>de", function() dapui.eval() end,   desc = "[d]ap [e]val", mode = { "n" } },
  })
end

local neotest = utils.prequire("neotest")
if neotest then
  wk.add({
    { "<leader>ta", function() neotest.run.attach() end,                                      desc = "[t]est [a]ttach",       mode = { "n" } },
    { "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end,                       desc = "[t]est run [f]ile",     mode = { "n" } },
    { "<leader>tA", function() neotest.run.run(vim.uv.cwd()) end,                             desc = "[t]est [A]ll files",    mode = { "n" } },
    { "<leader>tS", function() neotest.run.run({ suite = true }) end,                         desc = "[t]est [S]uite",        mode = { "n" } },
    { "<leader>tn", function() neotest.run.run() end,                                         desc = "[t]est [n]earest",      mode = { "n" } },
    { "<leader>tl", function() neotest.run.run_last() end,                                    desc = "[t]est [l]ast",         mode = { "n" } },
    { "<leader>ts", function() neotest.summary.toggle() end,                                  desc = "[t]est [s]ummary",      mode = { "n" } },
    { "<leader>to", function() neotest.output.open({ enter = true, auto_close = true }) end,  desc = "[t]est [o]utput",       mode = { "n" } },
    { "<leader>tO", function() neotest.output_panel.toggle() end,                             desc = "[t]est [O]utput panel", mode = { "n" } },
    { "<leader>tt", function() neotest.run.stop() end,                                        desc = "[t]est [t]erminate",    mode = { "n" } },
    { "<leader>td", function() neotest.run.run({ suite = false, strategy = "dap" }) end,      desc = "Debug nearest test",    mode = { "n" } },
    { "<leader>tD", function() neotest.run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Debug current file",    mode = { "n" } },
  })
end

local neorg = utils.prequire("neorg")
if neorg then
  wk.add({
    { "<leader>no", "<cmd>Neorg<cr>", desc = "Neorg", mode = "n" },
  })
end

local code_action = utils.prequire("tiny-code-action")
if code_action then
  wk.add({
    { "<leader>ca", function() code_action.code_action() end, desc = "LSP [C]ode [A]ction", mode = { "n" } },
  })
end

local undo_glow = utils.prequire("undo-glow")
if undo_glow then
  wk.add({
    { "u", function() undo_glow.undo() end,        desc = "Undo with highlight",        mode = { "n" } },
    { "U", function() undo_glow.redo() end,        desc = "Redo with highlight",        mode = { "n" } },
    { "p", function() undo_glow.paste_below() end, desc = "Paste below with highlight", mode = { "n" } },
    { "P", function() undo_glow.paste_above() end, desc = "Paste above with highlight", mode = { "n" } },
    {
      "n",
      function()
        undo_glow.search_next({
          animation = {
            animation_type = "strobe",
          },
        })
      end,
      desc = "Search next with highlight",
      mode = { "n" },
    },
    {
      "N",
      function()
        undo_glow.search_prev({
          animation = {
            animation_type = "strobe",
          },
        })
      end,
      desc = "Search prev with highlight",
      mode = { "n" },
    },
    {
      "*",
      function()
        undo_glow.search_star({
          animation = {
            animation_type = "strobe",
          },
        })
      end,
      desc = "Search star with highlight",
      mode = { "n" },
    },
    {
      "#",
      function()
        undo_glow.search_hash({
          animation = {
            animation_type = "strobe",
          },
        })
      end,
      desc = "Search hash with highlight",
      mode = { "n" },
    },
    {
      "gc",
      function() -- This is an implementation to preserve the cursor position
        local pos = vim.fn.getpos(".")
        vim.schedule(function()
          vim.fn.setpos(".", pos)
        end)
        return undo_glow.comment()
      end,
      desc = "Toggle comment with highlight",
      mode = { "n", "x" },
    },
    { "gc",  function() undo_glow.comment_textobject() end, desc = "Comment textobject with highlight",  mode = { "o" } },
    { "gcc", function() undo_glow.comment_line() end,       desc = "Toggle comment line with highlight", mode = { "n" } },
  })
end

local scratch = utils.prequire("scratch")
if scratch then
  wk.add({
    { "<leader>S", "<cmd>Scratch<cr>", desc = "New Scratch file", mode = { "n" } },
  })
  if fzf_lua then
    wk.add({
      {
        "<leader>.",
        function()
          fzf_lua.files({
            cwd = vim.fn.stdpath("cache") .. "/scratch.nvim",
            cwd_prompt = false,
            winopts = {
              title = "Scratch Files",
              title_flags = false,
            },
            keymap = {
              fzf = {
                ["ctrl-a"] = "select-all",
              }
            },
          })
        end,
        desc = "List Scratch files",
        mode = { "n" }
      },
    })
  end
end

local bufferline = utils.prequire("bufferline")
if bufferline then
  wk.add({
    { "<C-N>", "<cmd>BufferLineCycleNext<cr>", desc = "BufferLine next tab", mode = { "n" } },
    { "<C-P>", "<cmd>BufferLineCyclePrev<cr>", desc = "BufferLine prev tab", mode = { "n" } },
    { "<C-t>", "<cmd>tabnew<cr>",              desc = "New tab",             mode = { "n" } },
    { "<C-e>", "<cmd>new<cr>",                 desc = "New buffer",          mode = { "n" } },
  })
end

local overlook = utils.prequire("overlook.api")
if overlook then
  wk.add({
    { "<leader>pd", function() overlook.peek_definition() end,         desc = "Peek definition",              mode = { "n" } },
    { "<leader>pp", function() overlook.peek_cursor() end,             desc = "Peek cursor",                  mode = { "n" } },
    { "<leader>pu", function() overlook.restore_popup() end,           desc = "Restore last popup",           mode = { "n" } },
    { "<leader>pU", function() overlook.restore_all_popups() end,      desc = "Restore all popups",           mode = { "n" } },
    { "<leader>pc", function() overlook.close_all() end,               desc = "Close all popups",             mode = { "n" } },
    { "<leader>ps", function() overlook.open_in_split() end,           desc = "Open popup in split",          mode = { "n" } },
    { "<leader>pv", function() overlook.open_in_vsplit() end,          desc = "Open popup in vsplit",         mode = { "n" } },
    { "<leader>pt", function() overlook.open_in_tab() end,             desc = "Open popup in tab",            mode = { "n" } },
    { "<leader>po", function() overlook.open_in_original_window() end, desc = "Open popup in current window", mode = { "n" } },
  })
end
