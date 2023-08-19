-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "*.qml",
  },
  callback = function(event)
    vim.cmd({ cmd = "setfiletype", args = { "qmljs" } })

    vim.lsp.start({
      name = "qmlls",
      cmd = { "qmlls" },
      root_dir = vim.fs.dirname(vim.fs.find({ "CMakeLists.txt", ".git" }, { upward = true })[1]),
    })
  end,
})
