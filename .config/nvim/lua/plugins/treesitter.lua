return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNew", "VeryLazy" },
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "diff",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "rust",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
      "zig",
    },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.install").prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup(opts)
  end,
}
