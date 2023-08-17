local leading_key = "ms"

return {
  "https://github.com/echasnovski/mini.surround.git",
  opts = {
    mappings = {
      add = leading_key .. "a",
      delete = leading_key .. "d",
      find = leading_key .. "f",
      find_left = leading_key .. "F",
      highlight = leading_key .. "h",
      replace = leading_key .. "r",
      update_n_lines = leading_key .. "n",
    },
  },
}
