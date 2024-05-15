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
    { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Search help" },
    { "<leader>sm", "<cmd>Telescope man_pages<CR>", desc = "Search man pages" },
    { '<leader>s"', "<cmd>Telescope registers<CR>", desc = "Search registers" },
    { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Search keymaps" },
    { "<leader>sn", "<cmd>Telescope notify<CR>", desc = "Search notification history" },
    { "<leader>ss", "<cmd>Telescope builtin<CR>", desc = "Search select telescope" },
    { "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "Search current word" },
    { "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Search by grep" },
    { "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Search diagnostics" },
    { "<leader>sr", "<cmd>Telescope resume<CR>", desc = "Search resume" },
    { "<leader>s.", "<cmd>Telescope oldfiles<CR>", desc = "Search recent files" },
    { "<leader>bs", "<cmd>Telescope buffers<CR>", desc = "Find existing buffers" },
    { "<leader>/", desc = "Search in current buffer" },
    { "<leader>s/", desc = "Search in open files" },
    { "<leader>sc", desc = "Search config files" },
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

    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_cursor({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "Search in current buffer" })

    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Search in open files",
      })
    end, { desc = "Search in open files" })

    vim.keymap.set("n", "<leader>sc", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "Search config files" })
  end,
}
