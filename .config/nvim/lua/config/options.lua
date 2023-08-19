-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.relativenumber = false
opt.wrap = true
if vim.loop.os_uname().sysname == "Windows" then
  opt.shell = "pwsh"
end

local function append_val(enum, val)
  enum.append(enum, val)
end

append_val(opt.winbl, 25)
append_val(opt.pumblend, 25)

if vim.g.neovide then
  vim.opt.guifont = "SF Mono:h12"
end
