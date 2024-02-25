return {
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    config = true,
    opts = {
      outline_window = {
        width = 40,
        auto_close = true,
        show_numbers = true,
      },
      preview_window = {
        auto_preview = true,
      },
    },
  },
}
