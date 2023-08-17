return {
  {
    "enddeadroyal/symbols-outline.nvim",
    branch = "bugfix/symbol-hover-misplacement",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
    opts = {
      width = 40,
      auto_preview = true,
      show_numbers = true,
      auto_close = true,
    },
  },
}
