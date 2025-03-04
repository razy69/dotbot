--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

local open_with_trouble = require("trouble.sources.telescope").open


-- Dont preview binaries
local previewers = require("telescope.previewers")
local Job = require("plenary.job")
local new_maker = function(filepath, bufnr, opts)
  filepath = vim.fn.expand(filepath)
  Job:new({
    command = "file",
    args = { "--mime-type", "-b", filepath },
    on_exit = function(j)
      local mime_type = vim.split(j:result()[1], "/")[1]
      if mime_type == "text" then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      else
        -- maybe we want to write something to the buffer here
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
      end
    end
  }):sync()
end

require("telescope").setup({
  defaults = {
    buffer_previewer_maker = new_maker,
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    mappings = {
      i = {
        ["<C-t>"] = open_with_trouble,
        ["<C-h>"] = function(prompt_bufnr)
          -- Use nvim-window-picker to choose the window by dynamically attaching a function
          local action_set = require("telescope.actions.set")
          local action_state = require("telescope.actions.state")

          local picker = action_state.get_current_picker(prompt_bufnr)
          picker.get_selection_window = function(picker, entry)
            local picked_window_id = require("window-picker").pick_window() or vim.api.nvim_get_current_win()
            -- Unbind after using so next instance of the picker acts normally
            picker.get_selection_window = nil
            return picked_window_id
          end

          return action_set.edit(prompt_bufnr, "edit")
        end,
      },
      n = { ["<C-t>"] = open_with_trouble },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      previewer = false,
      theme = "dropdown",
      ignore_current_buffer = true,
    },
    find_files = { theme = "dropdown", previewer = false },
    git_files = { theme = "dropdown", previewer = false },
    registers = { theme = "dropdown" },
    lsp_code_actions = {
      theme = "cursor",
      layout_config = {
        height = 12,
      },
    },
    lsp_range_code_actions = { theme = "cursor" },
    loclist = { previewer = false },
  },
})

require("telescope").load_extension("noice")
require("telescope").load_extension("refactoring")
