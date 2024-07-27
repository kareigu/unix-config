return {
  {
    "echasnovski/mini.files",
    version = false,
    opts = {
      windows = { preview = true, width_preview = 80 },
      options = {
        use_as_default_explorer = false,
      },
    },
    keys = {
      {
        "<leader>f",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini files",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "ms",
        delete = "md",
        replace = "mr",
        highlight = "mh",
        find = "mf",
        find_left = "mF",
        update_lines = "mn",
      },
    },
  },
}
