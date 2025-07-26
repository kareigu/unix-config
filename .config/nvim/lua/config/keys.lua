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

vim.keymap.set("n", "<leader>bb", function()
  vim.cmd.b("#")
end, { desc = "Go to last buffer" })

vim.keymap.set("n", "<leader>bd", "<cmd>BufDel<cr>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>BufDel!<cr>", { desc = "Force close current buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufDelOthers<cr>", { desc = "Close all other buffers" })
vim.keymap.set("n", "<leader>bO", "<cmd>BufDelOthers!<cr>", { desc = "Force close all other buffers" })
vim.keymap.set("n", "<leader>bA", "<cmd>BufDelAll!<cr>", { desc = "Force close all buffers" })
