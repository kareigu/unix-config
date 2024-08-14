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
      vim.notify = require("notify")
    end,
  },
  {
    "julienvincent/hunk.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    cond = function()
      return vim.fn.executable("jj") == 1
    end,
    cmd = { "DiffEditor" },
    opts = {
      ui = {
        tree = {
          mode = "flat",
        },
        layout = "horizontal",
      },
    },
    config = true,
  },
}
