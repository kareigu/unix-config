---@type LazySpec
return {
  "ibhagwan/fzf-lua",
  opts = {},
  cmd = "FzfLua",
  keys = {
    { "<leader><leader>", "<cmd>FzfLua files<cr>", desc = "Search files" },
    {
      "<leader>.",
      function()
        require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Search files (cwd)",
    },
    { "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "Search help" },
    { "<leader>sm", "<cmd>FzfLua manpages<cr>", desc = "Search manpages" },
    { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Search registers" },
    { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Search keymaps" },
    { "<leader>ss", "<cmd>FzfLua<cr>", desc = "Search select" },
    { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Search jumplist" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Search current word" },
    { "<leader>sg", "<cmd>FzfLua live_grep_native<cr>", desc = "Search by grep" },
    {
      "<leader>sG",
      function()
        require("fzf-lua").live_grep_native({ cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Search by grep (cwd)",
    },
    { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Search diagnostics" },
    { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "Search resume" },
    { "<leader>bs", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    { "<leader>/", "<cmd>FzfLua blines<cr>", desc = "Search in current buffer" },
    { "<leader>s/", "<cmd>FzfLua lines<cr>", desc = "Search in open files" },
    {
      "<leader>sc",
      function()
        require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Search config files",
    },
  },
}
