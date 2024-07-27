---@type LazySpec
return {
  "MagicDuck/grug-far.nvim",
  ---@type GrugFarOptions
  ---@diagnostic disable-next-line: missing-fields
  opts = { transient = true },
  config = true,
  keys = {
    {
      "<leader>msr",
      "<CMD>GrugFar<CR>",
      desc = "Replace in files",
    },
    {
      "<leader>msw",
      function()
        require("grug-far").with_visual_selection()
      end,
      mode = "v",
      desc = "Search selection",
    },
  },
}
