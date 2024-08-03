vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set({ "n", "x" }, "m", "<Nop>")

vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Diagnostic error messages" })
vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Focus the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Focus the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Focus the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Focus the upper window" })

vim.keymap.set("n", "L", function()
  vim.cmd.bn()
end, { desc = "Next buffer" })
vim.keymap.set("n", "H", function()
  vim.cmd.bp()
end, { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>bd", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  if vim.bo[bufnr].modified then
    local choice = vim.fn.confirm("Unsaved changes in " .. buf_name .. ", save?", "&Yave\n&No\n&Cancel", "Cancel", "Question")
    if choice == 1 then
      vim.notify("Saved buffer", vim.log.levels.INFO, { title = buf_name })
      vim.cmd.write()
      vim.api.nvim_buf_delete(bufnr, { force = false })
    elseif choice == 2 then
      vim.notify("Closed buffer without saving", vim.log.levels.WARN, { title = buf_name })
      vim.api.nvim_buf_delete(bufnr, { force = true })
    else
      vim.notify("Cancelled closing buffer", vim.log.levels.WARN, { title = buf_name })
    end
  else
    vim.cmd.bd()
  end
end, { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bD", function()
  vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), { force = true })
  vim.notify("Closed buffer without saving", vim.log.levels.WARN)
end, { desc = "Force close current buffer" })
