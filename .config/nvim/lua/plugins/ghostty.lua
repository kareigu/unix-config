if vim.uv.os_uname().sysname == "Darwin" then
  ---@type LazySpec
  return {
    dir = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/",
    lazy = false,
    cond = vim.fn.executable("ghostty") == 1,
  }
end

if vim.uv.os_uname().sysname == "Linux" then
  ---@type LazySpec
  return {
    dir = "/usr/local/share/vim/vimfiles/",
    lazy = false,
    cond = vim.fn.executable("ghostty") == 1,
  }
end

return {}
