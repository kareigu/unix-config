return {
  "nvim-pack/nvim-spectre",
  build = false,
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  keys = {
    {
      "<leader>msr",
      function()
        require("spectre").open()
      end,
      desc = "Replace in files",
    },
    {
      "<leader>msw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search current word",
    },
    {
      "<leader>msw",
      function()
        require("spectre").open_visual()
      end,
      mode = "v",
      desc = "Search current word",
    },
    {
      "<leader>msf",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Search in current file",
    },
  },
}
