return {
  "rolv-apneseth/tfm.nvim",
  lazy = false,
  opts = {
    file_manager = "yazi",
    replace_netrw = true,
    enable_cmds = true,
    keybindings = {
      ["<ESC>"] = "q",
    },
  },
  keys = {
    {
      "<leader>e",
      ":Tfm<CR>",
      desc = "TFM",
    },
  },
}
