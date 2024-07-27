vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamed"
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
vim.o.textwidth = 100
vim.o.colorcolumn = "+1"
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
        { "m", group = "surround", mode = { "n", "x" } },
        { "<leader>m", icon = "󰇘 ", group = "misc", mode = { "n", "v" } },
        { "<leader>ms", icon = "󰛔 ", desc = "Search and replace", mode = { "n", "v" } },
        { "<leader>l", "<CMD>Lazy<CR>", icon = "󰒲 ", desc = "Lazy" },
        { "<leader>y", '"+y', icon = " ", desc = "Copy to clipboard" },
        { "<leader>Y", '"+Y', icon = " ", desc = "Copy line to clipboard" },
        { "<leader>p", '"+p', icon = " ", desc = "Paste from clipboard after selection" },
        { "<leader>P", '"+P', icon = " ", desc = "Paste from clipboard before selection" },
        {
          mode = { "v" },
          { "<leader>h", group = "git hunk" },
        },
      },
      icons = {
        ---@type wk.IconRule[]
        rules = {
          { plugin = "tfm.nvim", icon = " " },
          { plugin = "mason.nvim", icon = " " },
          { plugin = "dashboard-nvim", icon = "󰨇 " },
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
      keywordStyle = { italic = false },
      commentStyle = { italic = false },
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
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    keys = {
      {
        "<leader>q",
        "<CMD>Dashboard<CR>",
        desc = "Dashboard",
      },
    },
    opts = function()
      local logo = [[
                                                                                      
                                                                                      
                                                                                      
                                                 __~~                                 
                                             __@@@"@@L                                
                                          ~[@@@@@!@g"@!L                              
                                ,,~_ggg@@@@g[@@@@@@gg""                                
                              |@@@@@@@@@@@@@[@@@@@BN"                                 
                    ,gggg@@@@@@@@@@@@@@@@@@;@@@@@;@                                   
                     """""[@@@@@@@@@@@@@F"|@@@@@|@"                      ,@,          
                          "=@ggggggr===g_=4@@@P=                        |@@g,         
                               '""""@@@@@f"""                  .       _@[@"'         
                                 g@'  "@]                      *      gP'[=*          
                                 ""     "_                     B'    @| L9"           
               @_                  =___ __Tg=====__gggg_=g __   = : gg=               
                "1 ',       ___,,,"''"""@@LJ@W"""""""""[@@@@@L""_ __"                 
           mmmmm_____ggggdBBBBBBBBBT                          BBB@@@ggg_qg__          
          __ """""    _,                                          '""@@@@@@"""@@___   
                     @"!                                                  BBB@@~~BB   
                    [""'                                                              
                    ,.                                                                
                                                                                      
      ]]

      return {
        theme = "doom",
        hide = { statusline = false },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { key = "e", desc = "New file", action = "ene | startinsert", icon = " ", key_format = "%s" },
            { key = "r", desc = "Recent", action = "Telescope oldfiles", icon = " ", key_format = "%s" },
            { key = "s", desc = "Load last session", action = 'lua require("persistence").load()', icon = "󰱼 ", key_format = "%s" },
            { key = "l", desc = "Lazy", action = "Lazy", icon = "󰒲 ", key_format = "%s" },
            { key = "m", desc = "Mason", action = "Mason", icon = " ", key_format = "%s" },
            { key = "c", desc = "Config", action = "e $MYVIMRC", icon = " ", key_format = "%s" },
            { key = "q", desc = "Quit", action = "qa", icon = "󰅚 ", key_format = "%s" },
          },
        },
      }
    end,
  },

  {
    import = "plugins",
  },
}, { install = { colorscheme = { "kanagawa" } } })
