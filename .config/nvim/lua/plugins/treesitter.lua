---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNew", "VeryLazy" },
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  main = "nvim-treesitter.configs",
  ---@module "nvim-treesitter"
  ---@type TSConfig
  ---@diagnostic disable: missing-fields
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "diff",
      "html",
      "lua",
      "luadoc",
      "rust",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
      "zig",
    },
    auto_install = false,
    highlight = { enable = true, disable = { "markdown" } },
    indent = { enable = true },
  },
}
