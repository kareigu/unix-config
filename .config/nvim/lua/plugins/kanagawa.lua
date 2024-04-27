return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = true,
    },
    build = ":KanagawaCompile",
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
