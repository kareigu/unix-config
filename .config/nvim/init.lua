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
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"

if vim.g.neovide then
  vim.opt.guifont = "Mononoki Nerd Font Mono:h13"
  if vim.loop.os_uname().sysname == "Darwin" then
    vim.g.neovide_window_blurred = true
    vim.g.neovide_transparency = 0.7
  end
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
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
    config = function()
      require("which-key").setup()

      require("which-key").register({
        ["<leader>b"] = { name = "buffer", _ = "which_key_ignore" },
        ["<leader>c"] = { name = "code", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "debug", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "search", _ = "which_key_ignore" },
        ["<leader>u"] = { name = "ui", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "git", _ = "which_key_ignore" },
        ["<leader>x"] = { name = "session", _ = "which_key_ignore" },
        ["<leader>m"] = { name = "misc", _ = "which_key_ignore" },
        ["<leader>ms"] = { name = "Spectre", _ = "which_key_ignore" },
      })
      require("which-key").register({
        ["<leader>h"] = { "git hunk" },
        ["<leader>c"] = { "code" },
        ["<leader>m"] = { "misc" },
        ["<leader>ms"] = { "Spectre" },
      }, { mode = "v" })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    ---@type KanagawaConfig
    opts = {
      compile = true,
      transparent = true,
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
        "            :h-                                  Nhy`               ",
        "           -mh.                           h.    `Ndho               ",
        "           hmh+                          oNm.   oNdhh               ",
        "          `Nmhd`                        /NNmd  /NNhhd               ",
        "          -NNhhy                      `hMNmmm`+NNdhhh               ",
        "          .NNmhhs              ```....`..-:/./mNdhhh+               ",
        "           mNNdhhh-     `.-::///+++////++//:--.`-/sd`               ",
        "           oNNNdhhdo..://++//++++++/+++//++///++/-.`                ",
        "      y.   `mNNNmhhhdy+/++++//+/////++//+++///++////-` `/oos:       ",
        " .    Nmy:  :NNNNmhhhhdy+/++/+++///:.....--:////+++///:.`:s+        ",
        " h-   dNmNmy oNNNNNdhhhhy:/+/+++/-         ---:/+++//++//.`         ",
        " hd+` -NNNy`./dNNNNNhhhh+-://///    -+oo:`  ::-:+////++///:`        ",
        " /Nmhs+oss-:++/dNNNmhho:--::///    /mmmmmo  ../-///++///////.       ",
        "  oNNdhhhhhhhs//osso/:---:::///    /yyyyso  ..o+-//////////:/.      ",
        "   /mNNNmdhhhh/://+///::://////     -:::- ..+sy+:////////::/:/.     ",
        "     /hNNNdhhs--:/+++////++/////.      ..-/yhhs-/////////::/::/`    ",
        "       .ooo+/-::::/+///////++++//-/ossyyhhhhs/:///////:::/::::/:    ",
        "       -///:::::::////++///+++/////:/+ooo+/::///////.::://::---+`   ",
        "       /////+//++++/////+////-..//////////::-:::--`.:///:---:::/:   ",
        "       //+++//++++++////+++///::--                 .::::-------::   ",
        "       :/++++///////////++++//////.                -:/:----::../-   ",
        "       -/++++//++///+//////////////               .::::---:::-.+`   ",
        "       `////////////////////////////:.            --::-----...-/    ",
        "        -///://////////////////////::::-..      :-:-:-..-::.`.+`    ",
        "         :/://///:///::://::://::::::/:::::::-:---::-.-....``/- -   ",
        "           ::::://::://::::::::::::::----------..-:....`.../- -+oo/ ",
        "            -/:::-:::::---://:-::-::::----::---.-.......`-/.      ``",
        "           s-`::--:::------:////----:---.-:::...-.....`./:          ",
        "          yMNy.`::-.--::..-dmmhhhs-..-.-.......`.....-/:`           ",
        "         oMNNNh. `-::--...:NNNdhhh/.--.`..``.......:/-              ",
        "        :dy+:`      .-::-..NNNhhd+``..`...````.-::-`                ",
        "                        .-:mNdhh:.......--::::-`                    ",
        "                           yNh/..------..`                          ",
        "                                                                    ",
      }
      dashboard.section.header.opts.hl = "DiagnosticError"
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
