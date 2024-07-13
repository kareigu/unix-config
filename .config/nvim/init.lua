vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
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
vim.o.showbreak = "↪ "
vim.o.autoindent = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"

local transparent = true
if vim.g.neovide then
  vim.opt.guifont = "BerkeleyMono Nerd Font:h12"
  if vim.loop.os_uname().sysname == "Darwin" then
    vim.g.neovide_window_blurred = true
    vim.g.neovide_transparency = 0.7
  end
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  transparent = false
end

require("config.keys")
require("config.autocmd")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "tpope/vim-sleuth", event = "BufRead" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    ---@type wk.Opts
    opts = {
      preset = "helix",
      expand = 0,
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code", mode = { "n", "v" } },
        { "<leader>d", group = "debug" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
        { "<leader>g", group = "git" },
        { "<leader>x", group = "session" },
        { "<leader>m", icon = "󰇘 ", group = "misc", mode = { "n", "v" } },
        { "<leader>ms", icon = "󰛔 ", desc = "Spectre", mode = { "n", "v" } },
        { "<leader>l", "<CMD>Lazy<CR>", icon = "󰒲 ", desc = "Lazy" },
        {
          mode = { "v" },
          { "<leader>h", group = "git hunk" },
        },
      },
      icons = {
        ---@type wk.IconRule[]
        rules = {
          { plugin = "alpha-nvim", icon = "󰨇 " },
          { plugin = "tfm.nvim", icon = " " },
          { plugin = "mason.nvim", icon = " " },
        },
      },
    },
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    ---@type KanagawaConfig
    opts = {
      compile = true,
      transparent = transparent,
      ---@param colors KanagawaColors
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
          TelescopeTitle = { fg = theme.ui.special, bold = true },
          TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          TelescopePromptBorder = { fg = theme.ui.fg_dim, bg = theme.ui.bg_p1 },
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopeResultsBorder = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          TelescopePreviewNormal = { bg = theme.ui.bg_gutter },
          TelescopePreviewBorder = { bg = theme.ui.bg_p2, fg = theme.ui.fg_dim },
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
    "goolord/alpha-nvim",
    event = "VimEnter",
    keys = {
      {
        "<leader>q",
        function()
          vim.cmd["Alpha"]()
        end,
        desc = "Dashboard",
      },
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          vim.cmd.setlocal("nofoldenable")
          vim.b.ministatusline_disable = true
        end,
      })

      dashboard.section.header.val = {
        "                                                                              ",
        "                                                                              ",
        "                                                                              ",
        "                                         __~~                                 ",
        '                                     __@@@"@@L                                ',
        '                                  ~[@@@@@!@g"@!L                              ',
        '                        ,,~_ggg@@@@g[@@@@@@gg""                                ',
        '                      |@@@@@@@@@@@@@[@@@@@BN"                                 ',
        "            ,gggg@@@@@@@@@@@@@@@@@@;@@@@@;@                                   ",
        '             """""[@@@@@@@@@@@@@F"|@@@@@|@"                      ,@,          ',
        '                  "=@ggggggr===g_=4@@@P=                        |@@g,         ',
        '                       \'""""@@@@@f"""                  .       _@[@"\'         ',
        "                         g@'  \"@]                      *      gP'[=*          ",
        '                         ""     "_                     B\'    @| L9"           ',
        "       @_                  =___ __Tg=====__gggg_=g __   = : gg=               ",
        '        "1 \',       ___,,,"\'\'"""@@LJ@W"""""""""[@@@@@L""_ __"                 ',
        "   mmmmm_____ggggdBBBBBBBBBT                          BBB@@@ggg_qg__          ",
        '  __ """""    _,                                          \'""@@@@@@"""@@___   ',
        '             @"!                                                  BBB@@~~BB   ',
        '            [""\'                                                              ',
        "            ,.                                                                ",
        "                                                                              ",
      }
      dashboard.section.header.opts.hl = "PreProc"
      dashboard.opts.layout = {
        { type = "padding", val = 1 },
        dashboard.section.header,
        { type = "padding", val = 1 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      dashboard.section.buttons.val = {
        dashboard.button("e", "  󰫣 New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  󰫣 Recent", ":Telescope oldfiles<CR>"),
        dashboard.button("s", "󰱼  󰫣 Load last session", '<cmd>lua require("persistence").load({last = true})<CR>'),
        dashboard.button("l", "󰒲  󰫣 Lazy", ":Lazy<CR>"),
        dashboard.button("m", "  󰫣 Mason", ":Mason<CR>"),
        dashboard.button("c", "  󰫣 Config", ":e $MYVIMRC | Tfm<CR>"),
        dashboard.button("q", "󰅚  󰫣 Quit", ":qa<CR>"),
      }
      dashboard.section.buttons.opts.spacing = 0

      alpha.setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          local cwd = " " .. vim.fn.getcwd()
          local stats = require("lazy").stats()
          local plugins = " loaded " .. stats.loaded .. "/" .. stats.count .. " plugins"
          local time = (math.floor(stats.startuptime * 100 + 0.5) / 100) .. "ms 󰚭"

          dashboard.section.footer.val = {
            cwd,
            plugins .. " in " .. time,
          }
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  {
    import = "plugins",
  },
}, { install = { colorscheme = { "kanagawa" } } })
