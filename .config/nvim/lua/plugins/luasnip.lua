return {
  "L3MON4D3/LuaSnip",
  keys = {
    { "<tab>", mode = { "i", "s" }, false },
    { "<s-tab>", mode = { "i", "s" }, false },
    {
      "<C-K>",
      function()
        require("luasnip").expand()
      end,
      silent = true,
      mode = { "i", "s" },
    },
    {
      "<C-L>",
      function()
        require("luasnip").jump(1)
      end,
      silent = true,
      mode = { "i", "s" },
    },
    {
      "<C-J>",
      function()
        require("luasnip").jump(-1)
      end,
      silent = true,
      mode = { "i", "s" },
    },
  },
}
