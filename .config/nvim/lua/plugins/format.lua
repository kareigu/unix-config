local ft_formatters = {
  lua = { "stylua" },
  cmake = { "gersemi" },
  c = { "clang-format" },
  cpp = { "clang-format" },
  zig = { "zigfmt" },
  toml = { "taplo" },
  rust = { "rustfmt" },
  odin = { "odinfmt" },
}

local formatters = {
  odinfmt = {
    command = "odinfmt",
    args = { "-stdin" },
  },
}

return {
  "stevearc/conform.nvim",
  lazy = true,
  cmd = "ConformInfo",
  event = "BufWritePre",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      desc = "Format buffer",
    },
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "x", "v" },
      desc = "Format selection",
    },
  },
  opts = {
    notify_on_error = true,
    formatters_by_ft = ft_formatters,
    formatters = formatters,
  },
}
