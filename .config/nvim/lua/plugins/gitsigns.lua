return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNew" },
  keys = {
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Search commits" },
    { "<leader>gB", "<cmd>Telescope git_branches<CR>", desc = "Search branches" },
    { "<leader>gf", "<cmd>Telescope git_files<CR>", desc = "Search branches" },
  },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, { desc = "Next git change" })

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, { desc = "Previous git change" })

      -- Actions
      -- visual mode
      map("v", "<leader>gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Stage git hunk" })
      map("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset git hunk" })
      map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "git stage hunk" })
      map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "git reset hunk" })
      map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "git stage buffer" })
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "git undo stage hunk" })
      map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "git reset buffer" })
      map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "git preview hunk" })
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, { desc = "git blame line" })
      map("n", "<leader>gd", gitsigns.diffthis, { desc = "git diff against index" })
      map("n", "<leader>gD", function()
        gitsigns.diffthis("@")
      end, { desc = "git diff against last commit" })
      map("n", "<leader>ub", gitsigns.toggle_current_line_blame, { desc = "Toggle git show blame line" })
      map("n", "<leader>uD", gitsigns.toggle_deleted, { desc = "Toggle git show deleted" })
    end,
  },
}
