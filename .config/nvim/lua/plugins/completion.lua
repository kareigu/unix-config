return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v0.*",
  dependencies = {
    {
      "garymjr/nvim-snippets",
      opts = {
        create_autocmd = true,
        create_cmp_source = false,
        friendly_snippets = true,
      },
    },
    "rafamadriz/friendly-snippets",
  },
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-K>"] = { "show_documentation", "hide_documentation" },
      ["<C-L>"] = { "snippet_forward", "fallback" },
      ["<C-H>"] = { "snippet_backward", "fallback" },
      ["<Tab>"] = { "fallback" },
      ["<S-Tab>"] = { "fallback" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    signature = {
      enabled = true,
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      cmdline = {},
    },
    completion = {
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = false,
      },
    },
  },
}
