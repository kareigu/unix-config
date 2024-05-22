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
    opts = {},
    keys = { "s", desc = "surround" },
  },
  {
    "echasnovski/mini.pairs",
    opts = {},
    event = "InsertEnter",
  },
  {

    "echasnovski/mini.statusline",
    opts = {
      use_icons = true,
    },
    event = "BufEnter",
    config = function(opts)
      local statusline = require("mini.statusline")
      statusline.setup(opts)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
}