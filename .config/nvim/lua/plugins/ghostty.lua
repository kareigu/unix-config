if vim.loop.os_uname().sysname == "Darwin" then
  ---@type LazySpec
  return {
    dir = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/",
    lazy = false,
    cond = vim.fn.executable("ghostty") == 1,
  }
end

return {}
