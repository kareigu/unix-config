-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function unmap(mode, lhs, opts)
  vim.keymap.del(mode, lhs, opts)
end

local lazyterm = function()
  Util.float_term(nil, { cwd = Util.get_root() })
end
map("n", "<leader>t", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>T", function()
  Util.float_term()
end, { desc = "Terminal (cwd)" })

unmap("n", "<leader>ft", { desc = "Terminal (root dir)" })
unmap("n", "<leader>fT", { desc = "Terminal (cwd)" })

map("n", "<leader>ft", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    select_buffer = true,
  })
end, { desc = "Open file browser (cwd)" })
map("n", "<leader>fT", function()
  require("telescope").extensions.file_browser.file_browser()
end, { desc = "Open file browser" })

if vim.g.neovide then
  map("n", "<leader>mF", function()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end, { desc = "Toggle fullscreen" })
end
