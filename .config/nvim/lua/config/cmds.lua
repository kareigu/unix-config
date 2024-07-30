vim.api.nvim_create_user_command("OpenConfig", function()
  vim.fn.chdir(vim.fn.stdpath("config"))
  vim.cmd.edit("$MYVIMRC")
end, {})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("krg_last_location", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit", "jjdescription" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].krg_last_location then
      return
    end
    vim.b[buf].krg_last_location = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("krg_wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "jjdescription" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
