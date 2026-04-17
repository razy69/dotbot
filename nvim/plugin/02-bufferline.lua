-- Tab/buffer line with catppuccin integration
plugin.add({
  name = "bufferline",
  src = "https://github.com/akinsho/bufferline.nvim",
  event = plugin.LazyFile,
  keys = {
    { "<C-N>", desc = "BufferLine next tab", mode = "n" },
    { "<C-P>", desc = "BufferLine prev tab", mode = "n" },
    { "<C-t>", desc = "New tab",             mode = "n" },
    { "<C-e>", desc = "New buffer",          mode = "n" },
  },
  config = function()
    -- Configure bufferline
    local palette = utils.get_palette()
    local bufferline = require("bufferline")

    bufferline.setup({
      options = {
        mode = "tabs",
        show_buffer_close_icons = true,
        show_buffer_icons = true,
      },
      highlights = require("catppuccin.special.bufferline").get_theme({
        styles = { "bold" },
        custom = {
          palette = {
            background = {
              fg = palette.text,
              bg = palette.base,
            },
          }
        }
      })
    })

    -- Add keymap
    utils.wk_add({
      { "<C-N>", "<cmd>BufferLineCycleNext<cr>", desc = "BufferLine next tab", mode = { "n" } },
      { "<C-P>", "<cmd>BufferLineCyclePrev<cr>", desc = "BufferLine prev tab", mode = { "n" } },
      { "<C-t>", "<cmd>tabnew<cr>",              desc = "New tab",             mode = { "n" } },
      { "<C-e>", "<cmd>new<cr>",                 desc = "New buffer",          mode = { "n" } },
    })
  end,
})
