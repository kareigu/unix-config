-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.relativenumber = false
opt.wrap = true
if vim.loop.os_uname().sysname == "Windows_NT" then
  opt.shell = "pwsh"
end

local function append_val(enum, val)
  enum.append(enum, val)
end

append_val(opt.winbl, 25)
append_val(opt.pumblend, 25)

if vim.g.neovide then
  vim.opt.guifont = "Mononoki Nerd Font Mono:h13"
  vim.g.neovide_window_blurred = true
  vim.g.neovide_transparency = 0.7
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
end
