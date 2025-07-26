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

local ok, local_fmt = pcall(require, "local_fmt")
if ok then
  if local_fmt.ft_formatters ~= nil then
    ft_formatters = vim.tbl_deep_extend("force", ft_formatters, local_fmt.ft_formatters)
  end
  if local_fmt.formatters ~= nil then
    formatters = vim.tbl_deep_extend("force", formatters, local_fmt.formatters)
  end
else
  vim.print("error loading local_fmt")
end

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
    {
      "<leader>ci",
      "<cmd>ConformInfo<cr>",
      desc = "Formatter info",
    },
  },
  opts = {
    notify_on_error = true,
    formatters_by_ft = ft_formatters,
    formatters = formatters,
  },
}
