-- Toggle/cycle booleans and other values with <C-a>/<C-x>
plugin.add({
  name = "boole",
  src = "https://github.com/nat-418/boole.nvim",
  keys = {
    { "<C-a>", desc = "Increment" },
    { "<C-x>", desc = "Decrement" },
  },
  config = function()
    require("boole").setup({
      mappings = {
        increment = "<C-a>",
        decrement = "<C-x>",
      },
    })
  end,
})
