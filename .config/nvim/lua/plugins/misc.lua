return {
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  {
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = function()
      vim.notify = require("notify")
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "rolv-apneseth/tfm.nvim",
    lazy = false,
    opts = {
      file_manager = "yazi",
      replace_netrw = true,
      enable_cmds = true,
      keybindings = {
        ["<ESC>"] = "q",
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("tfm").open(nil, nil)
        end,
        desc = "TFM",
      },
    },
  },
  {
    "julienvincent/hunk.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
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
