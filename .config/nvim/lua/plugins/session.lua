---@type LazySpec
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = { options = vim.opt.sessionoptions:get() },
  keys = {
    {
      "<leader>xr",
      function()
        require("persistence").load()
        vim.notify("CWD session loaded", vim.log.levels.INFO)
      end,
      desc = "Load session for current directory",
    },
    {
      "<leader>xl",
      function()
        require("persistence").load({ last = true })
        vim.notify("Last session loaded", vim.log.levels.INFO)
      end,
      desc = "Load last session",
    },
    {
      "<leader>xd",
      function()
        require("persistence").stop()
        vim.notify("Disabled automatically saving session", vim.log.levels.INFO)
      end,
      desc = "Don't automatically save current session",
    },
    {
      "<leader>xD",
      function()
        require("persistence").start()
        vim.notify("Automatically saving session", vim.log.levels.INFO)
      end,
      desc = "Automatically save current session",
    },
    {
      "<leader>xs",
      function()
        require("persistence").save()
        vim.notify("Saved session", vim.log.levels.INFO)
      end,
      desc = "Save current session",
    },
  },
}
