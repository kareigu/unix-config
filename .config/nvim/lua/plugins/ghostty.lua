---@return string
local function get_dir()
  if vim.loop.os_uname().sysname == "Darwin" then
    return "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/"
  end
  error("Unsupported platform")
end
---@type LazySpec
return {
  dir = get_dir(),
  lazy = false,
  cond = function()
    return vim.fn.executable("ghostty") == 1
  end,
}
