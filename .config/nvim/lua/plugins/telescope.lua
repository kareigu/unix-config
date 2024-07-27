---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons" },
  },
  keys = {
    { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Search files" },
    {
      "<leader>.",
      function()
        require("telescope.builtin").find_files({ cwd = require("telescope.utils").buffer_dir() })
      end,
      desc = "Search files (cwd)",
    },
    { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Search help" },
    { "<leader>sm", "<cmd>Telescope man_pages<CR>", desc = "Search man pages" },
    { '<leader>s"', "<cmd>Telescope registers<CR>", desc = "Search registers" },
    { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Search keymaps" },
    { "<leader>sn", "<cmd>Telescope notify<CR>", desc = "Search notification history" },
    { "<leader>ss", "<cmd>Telescope builtin<CR>", desc = "Search select telescope" },
    { "<leader>sj", "<cmd>Telescope jumplist<CR>", desc = "Search jumplist" },
    { "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "Search current word" },
    { "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Search by grep" },
    {
      "<leader>sG",
      function()
        require("telescope.builtin").live_grep({ cwd = require("telescope.utils").buffer_dir() })
      end,
      desc = "Search by grep (cwd)",
    },
    { "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Search diagnostics" },
    { "<leader>sr", "<cmd>Telescope resume<CR>", desc = "Search resume" },
    { "<leader>s.", "<cmd>Telescope oldfiles<CR>", desc = "Search recent files" },
    { "<leader>bs", "<cmd>Telescope buffers<CR>", desc = "Find existing buffers" },
    {
      "<leader>/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = true,
        }))
      end,
      desc = "Search in current buffer",
    },
    {
      "<leader>s/",
      function()
        require("telescope.builtin").live_grep({
          grep_open_files = true,
          prompt_title = "Search in open files",
        })
      end,
      desc = "Search in open files",
    },
    {
      "<leader>sc",
      function()
        local config_path = vim.fn.stdpath("config")
        require("telescope.builtin").find_files({ cwd = config_path, prompt_title = "Search config files: " .. config_path })
      end,
      desc = "Search config files",
    },
  },
  config = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
  end,
}
