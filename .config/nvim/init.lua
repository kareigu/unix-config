vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = true
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.autocomplete = true
vim.opt.completeopt = "noselect,menuone,fuzzy"
vim.o.pumborder = "rounded"
vim.o.textwidth = 100
vim.o.colorcolumn = "+1"
vim.o.showbreak = "↪ "
vim.o.autoindent = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"

local transparent = true
if vim.g.neovide then
  vim.opt.guifont = "TX-02,Symbols Nerd Font Mono:h13:#e-subpixelantialias:#h-none"
  if vim.uv.os_uname().sysname == "Darwin" then
    vim.g.neovide_window_blurred = true
    vim.g.neovide_transparency = 0.7
  end
  vim.g.neovide_title_background_color = "#1F1F28"
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_floating_corner_radius = 0.5
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  transparent = false
end

local function map(binds)
  for _, bind in ipairs(binds) do
    if bind[4] ~= nil then
      vim.keymap.set(bind[1], bind[2], bind[3], bind[4])
    else
      vim.keymap.set(bind[1], bind[2], bind[3])
    end
  end
end

-- KEYS
map({
  { "n", "<Esc>", "<cmd>nohlsearch<CR>" },
  { { "n", "x" }, "m", "<Nop>" },
})

map({
  { "n", "<leader>ce", vim.diagnostic.open_float, { desc = "Diagnostic error messages" } },
  { "n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" } },
  { "t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" } },
})

map({
  { "n", "<C-h>", "<C-w><C-h>", { desc = "Focus the left window" } },
  { "n", "<C-l>", "<C-w><C-l>", { desc = "Focus the right window" } },
  { "n", "<C-j>", "<C-w><C-j>", { desc = "Focus the lower window" } },
  { "n", "<C-k>", "<C-w><C-k>", { desc = "Focus the upper window" } },
})

map({
  { "n", "L", "<cmd>bn<cr>", { desc = "Next buffer" } },
  { "n", "H", "<cmd>bp<cr>", { desc = "Previous buffer" } },
  { "n", "<leader>bb", "<cmd>b #<cr>", { desc = "Go to last buffer" } },
})


vim.keymap.set("n", "<leader>bd", "<cmd>BufDel<cr>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>BufDel!<cr>", { desc = "Force close current buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufDelOthers<cr>", { desc = "Close all other buffers" })
vim.keymap.set("n", "<leader>bO", "<cmd>BufDelOthers!<cr>", { desc = "Force close all other buffers" })
vim.keymap.set("n", "<leader>bA", "<cmd>BufDelAll!<cr>", { desc = "Force close all buffers" })
-- END KEYS

-- COMMANDS
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
-- END COMMANDS

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      expand = 0,
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code", mode = { "n", "v" } },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "session" },
        { "<leader>m", icon = "󰇘 ", group = "misc", mode = { "n", "v" } },
        { "<leader>ms", icon = "󰛔 ", desc = "Search and replace", mode = { "n", "v" } },
        { "<leader>l", "<CMD>Lazy<CR>", icon = "󰒲 ", desc = "Lazy" },
        { "<leader>y", '"+y', icon = " ", desc = "Copy to clipboard", mode = { "n", "x", "v", "t" } },
        { "<leader>Y", '"+Y', icon = " ", desc = "Copy line to clipboard" },
        { "<leader>p", '"+p', icon = " ", desc = "Paste from clipboard after selection" },
        { "<leader>P", '"+P', icon = " ", desc = "Paste from clipboard before selection" },
        {
          mode = { "v" },
          { "<leader>g", group = "git hunk" },
        },
      },
    },
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    opts = {
      compile = true,
      transparent = transparent,
      keywordStyle = { italic = false },
      commentStyle = { italic = false },
      overrides = function(colors)
        local theme = colors.theme
        return {
          MiniStatuslineModeNormal = { fg = colors.theme.ui.fg, bg = colors.palette.waveRed },
          MiniStatuslineModeInsert = { fg = colors.theme.ui.bg_m1, bg = colors.palette.springBlue },
          MiniStatuslineModeVisual = { fg = colors.theme.ui.fg, bg = colors.palette.lotusGreen },
          MiniStatuslineModeReplace = { fg = colors.theme.ui.fg, bg = colors.palette.lotusOrange },
          MiniStatuslineModeCommand = { fg = colors.theme.ui.fg, bg = colors.palette.fujiGray },
          MiniStatuslineModeOther = { fg = colors.theme.ui.fg, bg = colors.palette.lotusCyan },
          MiniStatuslineFileinfo = { fg = colors.theme.ui.fg_dim, bg = colors.theme.ui.whitespace },
          MiniStatuslineFilename = { fg = colors.theme.ui.fg, bg = colors.theme.ui.bg_p2, italic = true },
          MiniStatuslineDevinfo = { fg = colors.theme.ui.special, bg = colors.theme.ui.bg_m3 },
          MiniStatuslineInactive = { fg = colors.theme.ui.fg_dim, bg = colors.theme.ui.bg_dim, italic = true },
          Pmenu = { fg = theme.ui.fg, bg = theme.ui.bg_p1, blend = vim.o.pumblend },
          PmenuSel = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.fg_dim },
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        }
      end,
    },
    init = function()
      vim.cmd.colorscheme("kanagawa")
    end,
    build = ":KanagawaCompile",
  },
  {
    import = "plugins",
  },
}, { install = { colorscheme = { "kanagawa" } } })
