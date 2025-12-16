---@type LazySpec
return {
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "ys",
        delete = "ds",
        replace = "cs",
        highlight = "sh",
        find = "sf",
        find_left = "sF",
        update_lines = "sn",
        suffix_last = "",
        suffix_next = "",
      },
      search_method = "cover_or_next",
      custom_surroundings = {
        ["B"] = { output = { left = "{", right = "}" } },
      },
    },
    keys = {
      { "S", "ys", desc = "surround selection", remap = true, mode = "x" },
      { "yss", "ys_", desc = "surround line", remap = true },
    },
  },
}
