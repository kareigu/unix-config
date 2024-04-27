return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = true },
    ---@type lspconfig.options
    servers = {
      clangd = {
        mason = false,
      },
      rust_analyzer = {
        mason = false,
      },
      zls = {
        mason = false,
      },
    },
  },
}
