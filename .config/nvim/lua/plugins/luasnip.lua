return {
  "L3MON4D3/LuaSnip",
  keys = {
    { "<tab>", nil, mode = "s", "i" },
    { "<s-tab>", nil, mode = { "i", "s" } },
    {
      "<C-K>",
      function()
        require("luasnip").expand()
      end,
      silent = true,
      mode = { "i" },
    },
    {
      "<C-L>",
      function()
        require("luasnip").jump(1)
      end,
      silent = true,
      mode = { "i" },
    },
    {
      "<C-J>",
      function()
        require("luasnip").jump(-1)
      end,
      silent = true,
      mode = { "i" },
    },
  },
}
