---@type LazySpec
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = { options = vim.opt.sessionoptions:get() },
  keys = {
    {
      "<leader>qr",
      function()
        require("persistence").load()
        vim.notify("CWD session loaded", vim.log.levels.INFO)
      end,
      desc = "Load session for current directory",
    },
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
        vim.notify("Last session loaded", vim.log.levels.INFO)
      end,
      desc = "Load last session",
    },
    {
      "<leader>qd",
      function()
        require("persistence").stop()
        vim.notify("Disabled automatically saving session", vim.log.levels.INFO)
      end,
      desc = "Don't automatically save current session",
    },
    {
      "<leader>qD",
      function()
        require("persistence").start()
        vim.notify("Automatically saving session", vim.log.levels.INFO)
      end,
      desc = "Automatically save current session",
    },
    {
      "<leader>qs",
      function()
        require("persistence").save()
        vim.notify("Saved session", vim.log.levels.INFO)
      end,
      desc = "Save current session",
    },
  },
}
