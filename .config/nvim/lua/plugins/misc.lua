---@type LazySpec
return {
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = function()
      require("notify").setup({ render = "compact" })
      vim.notify = require("notify")
    end,
  },
  {
    "ojroques/nvim-bufdel",
    cmd = { "BufDel", "BufDelOthers", "BufDelAll" },
    opts = {
      quit = false,
    },
  },
}
