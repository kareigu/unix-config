local function append_list(target, source)
  for _, v in ipairs(source) do
    table.insert(target, v)
  end
  return target
end
local function ansi_strip(str)
  return str:gsub("\27%[[%d;]*[a-zA-Z]", "")
end
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
vim.o.showbreak = "\226\134\170 "
vim.o.autoindent = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.env.MYVIMRC = (vim.fn.stdpath("config") .. "/init.fnl")
if ((vim.uv.os_uname().sysname == "Darwin") and (vim.fn.executable("ghostty") == 1)) then
  vim.opt.rtp:prepend("/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/")
else
end
local transparent = true
if vim.g.neovide then
  vim.opt.guifont = "TX-02,Symbols Nerd Font Mono:h13:#e-subpixelantialias:#h-none"
  if (vim.uv.os_uname().sysname == "Darwin") then
    vim.g.neovide_window_blurred = true
    vim.g.neovide_transparency = 0.7
  else
  end
  vim.g.neovide_title_background_color = "#1F1F28"
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_floating_corner_radius = 0.5
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  transparent = false
else
end
do
  vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
  vim.keymap.set({"n", "x"}, "m", "<Nop>")
end
do
  vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, {desc = "Diagnostic error messages"})
  vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, {desc = "Diagnostic quickfix list"})
  vim.keymap.set("n", "<leader>cc", "<cmd>Compile<cr>", {desc = "Compile"})
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
end
do
  vim.keymap.set("n", "<C-h>", "<C-w><C-h>", {desc = "Focus the left window"})
  vim.keymap.set("n", "<C-l>", "<C-w><C-l>", {desc = "Focus the right window"})
  vim.keymap.set("n", "<C-j>", "<C-w><C-j>", {desc = "Focus the lower window"})
  vim.keymap.set("n", "<C-k>", "<C-w><C-k>", {desc = "Focus the upper window"})
end
do
  vim.keymap.set("n", "L", "<cmd>bn<cr>", {desc = "Next buffer"})
  vim.keymap.set("n", "H", "<cmd>bp<cr>", {desc = "Previous buffer"})
  vim.keymap.set("n", "<leader>bb", "<cmd>b #<cr>", {desc = "Go to last buffer"})
end
do
  vim.keymap.set("n", "<leader>ll", "<cmd>ListPackages<cr>", {desc = "List packages"})
  local function _4_()
    return vim.pack.update()
  end
  vim.keymap.set("n", "<leader>lu", _4_, {desc = "Update packages"})
end
local function _5_()
  vim.fn.chdir(vim.fn.stdpath("config"))
  return vim.cmd.edit("$MYVIMRC")
end
vim.api.nvim_create_user_command("OpenConfig", _5_, {})
local function _6_()
  local config_path = vim.env.MYVIMRC
  local lua_config = (vim.fn.stdpath("config") .. "/init.lua")
  local write_config
  local function _7_(path, contents)
    local function _8_(err, fd)
      if (err or (fd == nil)) then
        return vim.notify(string.format("failed writing config: %s", (err or "unknown")), vim.log.levels.ERROR)
      else
        local function _9_(err0, bytes)
          if (err0 or (bytes ~= #contents)) then
            return vim.notify(string.format("failed writing config: %s", (err0 or "partial write")), vim.log.levels.ERROR)
          else
            return vim.notify(string.format("config written to %s", path), vim.log.levels.INFO)
          end
        end
        return vim.uv.fs_write(fd, contents, 0, _9_)
      end
    end
    return vim.uv.fs_open(path, "w", tonumber("644", 8), _8_)
  end
  write_config = _7_
  local on_exit
  local function _12_(obj)
    if (obj.code == 0) then
      vim.notify("compilation finished", vim.log.levels.INFO)
      return write_config(lua_config, obj.stdout)
    else
      return vim.notify(string.format("compilation failed: %s", ansi_strip(obj.stderr)), vim.log.levels.ERROR)
    end
  end
  on_exit = _12_
  if (vim.fn.executable("fennel") == 1) then
    vim.notify(string.format("compiling %s", config_path), vim.log.levels.INFO)
    return vim.system({"fennel", "-c", config_path}, {text = true}, on_exit)
  else
    return vim.notify("fennel not in path, unable to compile", vim.log.levels.ERROR)
  end
end
vim.api.nvim_create_user_command("CompileConfig", _6_, {})
local function _15_()
  local packages = vim.pack.get()
  local lines
  if (#packages == 0) then
    lines = {"No packages installed"}
  else
    local acc = {}
    for _, package in ipairs(packages) do
      local icon
      if package.active then
        icon = "\239\133\138 "
      else
        icon = "\239\148\176 "
      end
      acc = append_list(acc, {string.format("%s - %s", package.spec.name, icon), string.format("\tsrc = %s", package.spec.src), string.format("\trev = %s", package.rev), string.format("\tpath = %s", package.path), ""})
    end
    lines = acc
  end
  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, true, {relative = "editor", border = "rounded", width = (vim.o.columns - 6), height = (vim.o.lines - 6), col = 2, row = 2, style = "minimal"})
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  do
    local ns = vim.api.nvim_create_namespace("pkg_hl")
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    for i, package in ipairs(packages) do
      local line = ((i - 1) * 5)
      local header_len = (#lines[(line + 1)] - 6)
      local icon_colour
      if package.active then
        icon_colour = "DiagnosticOk"
      else
        icon_colour = "DiagnosticError"
      end
      vim.api.nvim_buf_add_highlight(bufnr, ns, "Title", line, 0, header_len)
      vim.api.nvim_buf_add_highlight(bufnr, ns, icon_colour, line, (header_len + 1), -1)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "Special", (line + 1), 0, -1)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "Number", (line + 2), 0, -1)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "Directory", (line + 3), 0, -1)
    end
  end
  vim.bo[bufnr]["modifiable"] = false
  vim.bo[bufnr]["modified"] = false
  vim.bo[bufnr]["bufhidden"] = "wipe"
  vim.bo[bufnr]["filetype"] = "pack-info"
  do
    vim.keymap.set("n", "q", "<cmd>close<cr>", {buffer = bufnr, nowait = true})
    vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", {buffer = bufnr})
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", {buffer = bufnr})
  end
  local function _19_()
    if vim.api.nvim_win_is_valid(winid) then
      return vim.api.nvim_win_close(winid, true)
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd("BufLeave", {desc = "Close pack info on buffer closure", buffer = bufnr, once = true, nested = true, callback = _19_})
end
vim.api.nvim_create_user_command("ListPackages", _15_, {})
local function _21_(opts)
  if (vim.g.krg_compile_last_command == nil) then
    vim.g.krg_compile_last_command = "ninja -C build"
  else
  end
  local handle_compile
  local function _23_(input)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, true, {relative = "editor", border = "rounded", width = (vim.o.columns - 6), height = (vim.o.lines - 6), col = 2, row = 2, style = "minimal"})
    local handle_output
    local function _24_(err, data)
      local case_25_, case_26_ = err, data
      if ((nil ~= case_25_) and true) then
        local err0 = case_25_
        local _ = case_26_
        return vim.notify(err0, vim.log.levels.ERROR)
      elseif ((case_25_ == nil) and (nil ~= case_26_)) then
        local data0 = case_26_
        local function _27_()
          if vim.api.nvim_win_is_valid(winid) then
            return vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, vim.split(ansi_strip(data0), "\n", {trimempty = true}))
          else
            return nil
          end
        end
        return vim.schedule(_27_)
      else
        return nil
      end
    end
    handle_output = _24_
    local stdout = vim.uv.new_pipe()
    local stderr = vim.uv.new_pipe()
    local args = vim.split(input, "%s")
    local cmd = table.remove(args, 1)
    local handle, pid, err
    local function _30_(code, signal)
      local function _31_()
        if vim.api.nvim_win_is_valid(winid) then
          vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {string.format("-- exited with code %d --", code)})
          stdout:read_stop()
          stderr:read_stop()
          vim.bo[bufnr]["modifiable"] = false
          if handle then
            return handle:close()
          else
            return nil
          end
        else
          return nil
        end
      end
      return vim.schedule(_31_)
    end
    handle, pid, err = vim.uv.spawn(cmd, {args = args, stdio = {nil, stdout, stderr}, hide = true}, _30_)
    if err then
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {string.format("-- failed running: %s --", err)})
    else
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, {string.format("-- running(%d): %s --", pid, input)})
      vim.uv.read_start(stdout, handle_output)
      vim.uv.read_start(stderr, handle_output)
    end
    vim.bo[bufnr]["modified"] = false
    vim.bo[bufnr]["bufhidden"] = "wipe"
    vim.bo[bufnr]["filetype"] = "compilation"
    do
      vim.keymap.set("n", "q", "<cmd>close<cr>", {buffer = bufnr, nowait = true})
      vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", {buffer = bufnr})
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", {buffer = bufnr})
      local function _35_()
        if (handle and not handle:is_closing()) then
          handle:kill()
          return vim.notify("compilation aborted")
        else
          return nil
        end
      end
      vim.keymap.set("n", "c", _35_, {buffer = bufnr})
      local function _37_()
        if vim.api.nvim_win_is_valid(winid) then
          return vim.api.nvim_win_set_config(winid, {split = "right", win = vim.fn.win_getid(vim.fn.winnr("#"))})
        else
          return nil
        end
      end
      vim.keymap.set("n", "o", _37_, {buffer = bufnr})
    end
    local function _39_()
      if (handle and handle:is_closing()) then
        stdout:read_stop()
        stderr:read_stop()
        handle:kill()
      else
      end
      if vim.api.nvim_win_is_valid(winid) then
        return vim.api.nvim_win_close(winid, true)
      else
        return nil
      end
    end
    return vim.api.nvim_create_autocmd("BufUnload", {desc = "Close compilation window on buffer close", buffer = bufnr, once = true, nested = true, callback = _39_})
  end
  handle_compile = _23_
  if (#opts.args > 0) then
    return handle_compile(opts.args)
  else
    local function _42_(input)
      if input then
        if (#input == 0) then
          vim.g.krg_compile_last_command = nil
          return vim.notify("Empty command not allowed", vim.log.levels.ERROR)
        else
          vim.g.krg_compile_last_command = input
          return handle_compile(input)
        end
      else
        return nil
      end
    end
    return vim.ui.input({prompt = "Compile: ", default = vim.g.krg_compile_last_command, completion = "shellcmdline"}, _42_)
  end
end
vim.api.nvim_create_user_command("Compile", _21_, {desc = "Run compilation command and display the output in a buffer", complete = "shellcmdline", nargs = "*"})
local function _46_(event)
  local buf = event.buf
  local exclude = {"gitcommit", "jjdescription"}
  local excluded = vim.tbl_contains(exclude, vim.bo[buf].filetype)
  local l_loc = vim.b[buf].krg_last_location
  if not (excluded or l_loc) then
    vim.b[buf]["krg_last_location"] = true
    local mark = vim.api.nvim_buf_get_mark(buf, "\"")
    local lcount = vim.api.nvim_buf_line_count(buf)
    if ((mark[1] > 0) and (mark[1] <= lcount)) then
      return pcall(vim.api.nvim_win_set_cursor, 0, mark)
    else
      return nil
    end
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufReadPost", {group = vim.api.nvim_create_augroup("krg_last_location", {clear = true}), callback = _46_})
local function _49_()
  vim.opt_local.wrap = true
  vim.opt_local.spell = true
  return nil
end
vim.api.nvim_create_autocmd("FileType", {group = vim.api.nvim_create_augroup("krg_wrap_spell", {clear = true}), pattern = {"gitcommit", "markdown", "jjdescription"}, callback = _49_})
local function _50_()
  return vim.highlight.on_yank()
end
vim.api.nvim_create_autocmd("TextYankPost", {desc = "Highlight yanked text", group = vim.api.nvim_create_augroup("highlight-yank", {clear = true}), callback = _50_})
local function _51_()
  return vim.cmd("CompileConfig")
end
vim.api.nvim_create_autocmd("BufWritePost", {pattern = vim.env.MYVIMRC, callback = _51_})
local INSTANT = 1
local DEFER = 2
local packages_to_install = {}
local on_update_hooks = {}
local function append_package(load_time, spec)
  if not packages_to_install[load_time] then
    packages_to_install[load_time] = {urls = {spec.src}, setups = {spec.setup}, deps = {(spec.deps or {})}}
    return nil
  else
    local len = #packages_to_install[load_time].urls
    packages_to_install[load_time]["urls"][(len + 1)] = spec.src
    packages_to_install[load_time]["setups"][(len + 1)] = (spec.setup or false)
    packages_to_install[load_time]["deps"][(len + 1)] = (spec.deps or {})
    return nil
  end
end
local function init_pack()
  local function add_and_setup(specs)
    vim.pack.add(specs.urls)
    for _, setup in ipairs(specs.setups) do
      if setup() then
        setup()
      else
      end
    end
    for _, deps in ipairs(specs.deps) do
      vim.pack.add(deps)
    end
    return nil
  end
  for load_time, specs in pairs(packages_to_install) do
    if (load_time == INSTANT) then
      add_and_setup(specs)
    elseif (load_time == DEFER) then
      local function _54_()
        return add_and_setup(specs)
      end
      vim.schedule(_54_)
    elseif (nil ~= load_time) then
      local event = load_time
      local function _55_()
        return add_and_setup(specs)
      end
      vim.api.nvim_create_autocmd(event, {once = true, callback = _55_})
    else
    end
  end
  local function _57_(ev)
    if (ev.data.kind == "update") then
      for _, hook in ipairs(on_update_hooks) do
        if (hook[1] == ev.data.spec.src) then
          if not ev.data.active then
            vim.cmd.packadd(ev.data.spec.name)
          else
          end
          vim.cmd(hook[2])
        else
        end
      end
      return nil
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd("PackChanged", {callback = _57_})
end
do
  local s_2_auto
  local function _61_()
    do
      local kanagawa = require("kanagawa")
      local overrides
      local function _62_(colors)
        local theme = colors.theme
        local palette = colors.palette
        return {MiniStatuslineModeNormal = {fg = theme.ui.fg, bg = palette.waveRed}, MiniStatuslineModeInsert = {fg = theme.ui.bg_m1, bg = palette.springBlue}, MiniStatuslineModeVisual = {fg = theme.ui.fg, bg = palette.lotusGreen}, MiniStatuslineModeReplace = {fg = theme.ui.fg, bg = palette.lotusOrange}, MiniStatuslineModeCommand = {fg = theme.ui.fg, bg = palette.fujiGray}, MiniStatuslineModeOther = {fg = theme.ui.fg, bg = palette.lotusCyan}, MiniStatuslineFileinfo = {fg = theme.ui.fg_dim, bg = theme.ui.whitespace}, MiniStatuslineFilename = {fg = theme.ui.fg, bg = theme.ui.bg_p2, italic = true}, MiniStatuslineDevinfo = {fg = theme.ui.special, bg = theme.ui.bg_m3}, MiniStatuslineInactive = {fg = theme.ui.fg_dim, bg = theme.ui.bg_dim, italic = true}, Pmenu = {fg = theme.ui.fg, bg = theme.ui.bg_p1, blend = vim.o.pumblend}, PmenuSel = {fg = theme.ui.fg_dim, bg = theme.ui.bg_p2}, PmenuSbar = {bg = theme.ui.bg_m1}, PmenuThumb = {bg = theme.ui.fg_dim}, NormalFloat = {bg = "none"}, FloatBorder = {bg = "none"}, FloatTitle = {bg = "none"}, NormalDark = {fg = theme.ui.fg_dim, bg = theme.ui.bg_m3}}
      end
      overrides = _62_
      kanagawa.setup({compile = true, transparent = transparent, keywordStyle = {italic = false}, commentStyle = {italic = false}, overrides = overrides})
    end
    return vim.cmd.colorscheme("kanagawa")
  end
  s_2_auto = {src = "https://github.com/rebelot/kanagawa.nvim", instant = true, on_update = "KanagawaCompile", setup = _61_}
  append_package(INSTANT, s_2_auto)
  table.insert(on_update_hooks, {s_2_auto.src, s_2_auto.on_update})
end
do
  local s_2_auto
  local function _63_()
    local ft_formatters = {lua = {"stylua"}, cmake = {"gersemi"}, c = {"clang-format"}, cpp = {"clang-format"}, zig = {"zigfmt"}, toml = {"taplo"}, rust = {"rustfmt"}, odin = {"odinfmt"}}
    local formatters = {odinfmt = {command = "odinfmt", args = {"-stdin"}}}
    do
      local ok, local_fmt = pcall(require, "local_fmt")
      if ok then
        if local_fmt.ft_formatters then
          ft_formatters = vim.tbl_deep_extend("force", ft_formatters, local_fmt.ft_formatters)
        else
        end
        if local_fmt.formatters then
          formatters = vim.tbl_deep_extend("force", formatters, local_fmt.formatters)
        else
        end
      else
        vim.notify("error loading local_fmt")
      end
    end
    return require("conform").setup({notify_on_error = true, formatters_by_ft = ft_formatters, formatters = formatters})
  end
  local function _67_()
    return require("conform").format({async = true})
  end
  local function _68_()
    return require("conform").format({async = true})
  end
  s_2_auto = {src = "https://github.com/stevearc/conform.nvim", setup = _63_, keys = {{mode = "n", keys = "<leader>cf", act = _67_, opts = {desc = "Format buffer"}}, {mode = {"x", "v"}, keys = "<leader>cf", act = _68_, opts = {desc = "Format selection"}}, {mode = "n", keys = "<leader>ci", act = "<cmd>ConformInfo<cr>", opts = {desc = "Formatter info"}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _69_()
    return require("which-key").setup({preset = "helix", expand = 0, spec = {{"<leader>b", group = "buffer"}, {"<leader>c", group = "code", mode = {"n", "v"}}, {"<leader>s", group = "search"}, {"<leader>u", group = "ui"}, {"<leader>g", group = "git"}, {"<leader>q", group = "session"}, {"<leader>m", icon = "\243\176\135\152 ", group = "misc", mode = {"n", "v"}}, {"<leader>ms", icon = "\243\176\155\148 ", desc = "Search and replace", mode = {"n", "v"}}, {"<leader>l", icon = "\239\146\135 ", group = "packages"}, {"<leader>y", "\"+y", icon = "\239\131\133 ", desc = "Copy to clipboard", mode = {"n", "x", "v", "t"}}, {"<leader>Y", "\"+Y", icon = "\239\131\133 ", desc = "Copy line to clipboard"}, {"<leader>p", "\"+p", icon = "\239\131\170 ", desc = "Paste from clipboard after selection"}, {"<leader>P", "\"+P", icon = "\239\131\170 ", desc = "Paste from clipboard before selection"}, {{"<leader>g", group = "git hunk"}, mode = {"v"}}}})
  end
  s_2_auto = {src = "https://github.com/folke/which-key.nvim", setup = _69_}
  append_package(DEFER, s_2_auto)
end
do
  local s_2_auto
  local function _70_()
    vim.g.lualine_laststatus = vim.o.laststatus
    if (vim.fn.argc(-1) > 0) then
      vim.o.statusline = " "
      return nil
    else
      vim.o.laststatus = 0
      return nil
    end
  end
  local function _72_()
    local get_hl
    local function _73_(name)
      return vim.api.nvim_get_hl(0, {name = name})
    end
    get_hl = _73_
    local get_colour
    local function _74_(name, key)
      return string.format("%x", get_hl(name)[key])
    end
    get_colour = _74_
    local colours = {bg = get_colour("StatusLine", "bg"), fg = get_colour("StatusLine", "fg"), inactive = get_colour("StatusLineNC", "fg"), filepath = get_colour("MiniStatuslineFilename", "fg"), fileinfo = get_colour("MiniStatuslineFileinfo", "fg"), vcs = get_colour("SpecialKey", "fg"), error = get_colour("DiagnosticError", "fg"), warn = get_colour("DiagnosticWarn", "fg"), info = get_colour("DiagnosticInfo", "fg"), mode = {normal = get_colour("MiniStatuslineModeNormal", "bg"), insert = get_colour("MiniStatuslineModeInsert", "bg"), visual = get_colour("MiniStatuslineModeVisual", "bg"), replace = get_colour("MiniStatuslineModeReplace", "bg"), command = get_colour("MiniStatuslineModeCommand", "bg"), other = get_colour("MiniStatuslineModeOther", "bg")}}
    local mode_color = {n = colours.mode.normal, no = colours.mode.normal, i = colours.mode.insert, v = colours.mode.visual, ["\22"] = colours.mode.visual, V = colours.mode.visual, c = colours.mode.command, ["!"] = colours.mode.command, t = colours.mode.command, R = colours.mode.replace, Rv = colours.mode.replace, r = colours.mode.replace, rm = colours.mode.replace, ["r?"] = colours.mode.replace, s = colours.mode.other, S = colours.mode.other, ["\19"] = colours.mode.other, ic = colours.mode.other, cv = colours.mode.other, ce = colours.mode.other}
    local conditions
    local function _75_()
      return (vim.fn.empty(vim.fn.expand("%:t")) ~= 1)
    end
    local function _76_()
      local filepath = vim.fn.expand("%:p:h")
      local gitdir = vim.fn.finddir(".git", (filepath .. ";"))
      return (gitdir and (#gitdir > 0) and (#gitdir < #filepath))
    end
    conditions = {buffer_not_empty = _75_, check_git_workspace = _76_}
    local opts
    local function _77_()
      return " \239\140\140 "
    end
    local function _78_()
      return {fg = mode_color[vim.fn.mode()]}
    end
    opts = {options = {component_separators = "", section_separators = "", theme = {normal = {c = {fg = colours.fg, bg = colours.bg}}, inactive = {c = {fg = colours.fg, bg = colours.bg}}}, global_status = (vim.o.laststatus == 3), disabled_filetypes = {statusline = {"dashboard"}}}, sections = {lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {{_77_, color = _78_, padding = {right = 1}}, {"filesize", cond = conditions.buffer_not_empty}, {"filename", cond = conditions.buffer_not_empty, color = {fg = colours.filepath, gui = "bold"}, newfile_status = true, path = 1}, "location", {"progress", color = {fg = colours.fg, gui = "bold"}}}, lualine_x = {{"o:encoding", fmt = string.upper, color = {fg = colours.fileinfo, gui = "bold"}}, {"fileformat", fmt = string.upper, color = {fg = colours.fileinfo, gui = "bold"}, icons_enabled = false}, {"branch", icon = "", color = {fg = colours.vcs, gui = "bold"}}, {"filetype", icons_enabled = true, color = {fg = colours.fileinfo, gui = "bold"}}}}, inactive_sections = {lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {}, lualine_x = {}}}
    for _, component in ipairs(opts.sections.lualine_c) do
      if (type(component) == "table") then
        local copy = vim.deepcopy(component)
        copy["color"] = {fg = colours.inactive}
        table.insert(opts.inactive_sections.lualine_c, copy)
      else
      end
    end
    for _, component in ipairs(opts.sections.lualine_x) do
      if (type(component) == "table") then
        local copy = vim.deepcopy(component)
        copy["color"] = {fg = colours.inactive}
        table.insert(opts.inactive_sections.lualine_x, copy)
      else
      end
    end
    return require("lualine").setup(opts)
  end
  s_2_auto = {src = "https://github.com/nvim-lualine/lualine.nvim", init = _70_, setup = _72_}
  append_package(DEFER, s_2_auto)
  s_2_auto.init()
end
do
  local s_2_auto
  local function _81_()
    do
      local ensure_installed = {"bash", "c", "cpp", "diff", "html", "lua", "luadoc", "rust", "toml", "vim", "vimdoc", "yaml", "zig"}
      require("nvim-treesitter").install(ensure_installed)
    end
    local function _82_()
      return vim.treesitter.start()
    end
    return vim.api.nvim_create_autocmd("FileType", {pattern = require("nvim-treesitter").get_installed(), callback = _82_})
  end
  s_2_auto = {src = {src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main"}, instant = true, on_update = "TSUpdate", setup = _81_}
  append_package(INSTANT, s_2_auto)
  table.insert(on_update_hooks, {s_2_auto.src.src, s_2_auto.on_update})
end
do
  local s_2_auto
  local function _83_()
    return require("todo-comments").setup({signs = false})
  end
  s_2_auto = {src = "https://github.com/folke/todo-comments.nvim", event = "BufReadPost", deps = {"https://github.com/nvim-lua/plenary.nvim"}, setup = _83_}
  append_package("BufReadPost", s_2_auto)
end
do
  local s_2_auto
  local function _84_()
    local icons = require("mini.icons")
    icons.setup()
    return icons.mock_nvim_web_devicons()
  end
  s_2_auto = {src = "https://github.com/nvim-mini/mini.icons", setup = _84_}
  append_package(DEFER, s_2_auto)
end
do
  local s_2_auto
  local function _85_()
    require("notify").setup({render = "compact"})
    vim.notify = require("notify")
    return nil
  end
  s_2_auto = {src = "https://github.com/rcarriga/nvim-notify", event = "VimEnter", setup = _85_}
  append_package("VimEnter", s_2_auto)
end
do
  local s_2_auto
  local function _86_()
    return require("bufdel").setup({quit = false})
  end
  s_2_auto = {src = "https://github.com/ojroques/nvim-bufdel", setup = _86_, keys = {{mode = "n", keys = "<leader>bd", act = "<cmd>BufDel<cr>", opts = {desc = "Close current buffer"}}, {mode = "n", keys = "<leader>bD", act = "<cmd>BufDel!<cr>", opts = {desc = "Force close current buffer"}}, {mode = "n", keys = "<leader>bo", act = "<cmd>BufDelOthers<cr>", opts = {desc = "Close all other buffers"}}, {mode = "n", keys = "<leader>bO", act = "<cmd>BufDelOthers!<cr>", opts = {desc = "Force close all other buffers"}}, {mode = "n", keys = "<leader>bA", act = "<cmd>BufDelAll!<cr>", opts = {desc = "Force close all buffers"}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _87_()
    return require("fzf-lua").setup({"ivy"})
  end
  local function _88_()
    return require("fzf-lua").files({cwd = vim.fn.expand("%:p:h")})
  end
  local function _89_()
    return require("fzf-lua").live_grep_native({cwd = vim.fn.expand("%:p:h")})
  end
  local function _90_()
    return require("fzf-lua").files({cwd = vim.fn.stdpath("config")})
  end
  s_2_auto = {src = "https://github.com/ibhagwan/fzf-lua", setup = _87_, keys = {{mode = "n", keys = "<leader><leader>", act = "<cmd>FzfLua files<cr>", opts = {desc = "Search files"}}, {mode = "n", keys = "<leader>.", act = _88_, opts = {desc = "Search files (cwd)"}}, {mode = "n", keys = "<leader>sh", act = "<cmd>FzfLua helptags<cr>", otps = {desc = "Search help"}}, {mode = "n", keys = "<leader>sm", act = "<cmd>FzfLua manpages<cr>", opts = {desc = "Search manpages"}}, {mode = "n", keys = "<leader>s\"", act = "<cmd>FzfLua registers<cr>", opts = {desc = "Search registers"}}, {mode = "n", keys = "<leader>sk", act = "<cmd>FzfLua keymaps<cr>", opts = {desc = "Search keymaps"}}, {mode = "n", keys = "<leader>ss", act = "<cmd>FzfLua<cr>", opts = {desc = "Search select"}}, {mode = "n", keys = "<leader>sj", act = "<cmd>FzfLua jumps<cr>", opts = {desc = "Search jumplist"}}, {mode = "n", keys = "<leader>sw", act = "<cmd>FzfLua grep_cword<cr>", opts = {desc = "Search current word"}}, {mode = "n", keys = "<leader>sg", act = "<cmd>FzfLua live_grep_native<cr>", opts = {desc = "Search by grep"}}, {mode = "n", keys = "<leader>sG", act = _89_, opts = {desc = "Search by grep (cwd)"}}, {mode = "n", keys = "<leader>sd", act = "<cmd>FzfLua diagnostics_workspace<cr>", opts = {desc = "Search diagnostics"}}, {mode = "n", keys = "<leader>sr", act = "<cmd>FzfLua resume<cr>", opts = {desc = "Search resume"}}, {mode = "n", keys = "<leader>bs", act = "<cmd>FzfLua buffers<cr>", opts = {desc = "Find buffers"}}, {mode = "n", keys = "<leader>/", act = "<cmd>FzfLua blines<cr>", opts = {desc = "Search in current buffer"}}, {mode = "n", keys = "<leader>s/", act = "<cmd>FzfLua lines<cr>", opts = {desc = "Search in open files"}}, {mode = "n", keys = "<leader>sc", act = _90_, opts = {desc = "Search config files"}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _91_()
    return require("mini.surround").setup({mappings = {add = "ys", delete = "ds", replace = "cs", highlight = "sh", find = "sf", find_left = "sF", update_lines = "sn", suffix_last = "", suffix_next = ""}, search_method = "cover_or_next", custom_surroundings = {B = {output = {left = "{", right = "}"}}}})
  end
  s_2_auto = {src = "https://github.com/nvim-mini/mini.surround", setup = _91_, keys = {{mode = "x", keys = "S", act = "ys", opts = {desc = "surround selection", remap = true}}, {mode = "n", keys = "yss", act = "ys_", opts = {desc = "surround line", remap = true}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _92_()
    local on_attach
    local function _93_(bufnr)
      local map
      local function _94_(mode, l, r, opts)
        local opts0 = (opts or {})
        opts0.buffer = bufnr
        return vim.keymap.set(mode, l, r, opts0)
      end
      map = _94_
      local gitsigns = require("gitsigns")
      local function _95_()
        if vim.wo.diff then
          return vim.cmd.normal({"]c", bang = true})
        else
          return gitsigns.nav_hunk("next")
        end
      end
      map("n", "]c", _95_, {desc = "Next git change"})
      local function _97_()
        if vim.wo.diff then
          return vim.cmd.normal({"[c", bang = true})
        else
          return gitsigns.nav_hunk("prev")
        end
      end
      map("n", "[c", _97_, {desc = "Previous git change"})
      local function _99_()
        return gitsigns.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
      end
      map("v", "<leader>gs", _99_, {desc = "Stage git hunk"})
      local function _100_()
        return gitsigns.reset_hunk({vim.fn.line("."), vim.fn.line("v")})
      end
      map("v", "<leader>gr", _100_, {desc = "Reset git hunk"})
      map("n", "<leader>gs", gitsigns.stage_hunk, {desc = "git stage hunk"})
      map("n", "<leader>gr", gitsigns.reset_hunk, {desc = "git reset hunk"})
      map("n", "<leader>gS", gitsigns.stage_buffer, {desc = "git stage buffer"})
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, {desc = "git undo stage hunk"})
      map("n", "<leader>gR", gitsigns.reset_buffer, {desc = "git reset buffer"})
      map("n", "<leader>gp", gitsigns.preview_hunk, {desc = "git preview hunk"})
      local function _101_()
        return gitsigns.blame_line({full = true})
      end
      map("n", "<leader>gb", _101_, {desc = "git blame line"})
      map("n", "<leader>gd", gitsigns.diffthis, {desc = "git diff against index"})
      local function _102_()
        return gitsigns.diffthis("@")
      end
      map("n", "<leader>gD", _102_, {desc = "git diff against last commit"})
      map("n", "<leader>ub", gitsigns.toggle_current_line_blame, {desc = "Toggle git show blame line"})
      return map("n", "<leader>uD", gitsigns.toggle_deleted, {desc = "Toggle git show deleted"})
    end
    on_attach = _93_
    return require("gitsigns").setup({on_attach = on_attach})
  end
  s_2_auto = {src = "https://github.com/lewis6991/gitsigns.nvim", event = {"BufReadPost", "BufNew"}, keys = {{mode = "n", keys = "<leader>gc", act = "<cmd>FzfLua git_commits<CR>", opts = {desc = "Search commits"}}, {mode = "n", keys = "<leader>gB", act = "<cmd>FzfLua git_branches<CR>", opts = {desc = "Search branches"}}, {mode = "n", keys = "<leader>gf", act = "<cmd>FzfLua git_files<CR>", opts = {desc = "Search files"}}}, setup = _92_}
  append_package({"BufReadPost", "BufNew"}, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _103_()
    return require("persistence").setup({options = vim.opt.sessionoptions:get()})
  end
  local function _104_()
    require("persistence").load()
    return vim.notify("CWD session loaded", vim.log.levels.INFO)
  end
  local function _105_()
    require("persistence").load({last = true})
    return vim.notify("Last session loaded", vim.log.levels.INFO)
  end
  local function _106_()
    require("persistence").stop()
    return vim.notify("Disabled automatically saving session", vim.log.levels.INFO)
  end
  local function _107_()
    require("persistence").start()
    return vim.notify("Automatically saving session", vim.log.levels.INFO)
  end
  local function _108_()
    require("persistence").save()
    return vim.notify("Saved session", vim.log.levels.INFO)
  end
  s_2_auto = {src = "https://github.com/folke/persistence.nvim", setup = _103_, keys = {{mode = "n", keys = "<leader>qr", act = _104_, opts = {desc = "Load session for current directory"}}, {mode = "n", keys = "<leader>ql", act = _105_, opts = {desc = "Load last session"}}, {mode = "n", keys = "<leader>qd", act = _106_, opts = {desc = "Don't automatically save current session"}}, {mode = "n", keys = "<leader>qD", act = _107_, opts = {desc = "Automatically save current session"}}, {mode = "n", keys = "<leader>qs", act = _108_, opts = {desc = "Save current session"}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
do
  local s_2_auto
  local function _109_()
    return require("grug-far").setup({transient = true})
  end
  local function _110_()
    return require("grug-far").with_visual_selection()
  end
  s_2_auto = {src = "https://github.com/MagicDuck/grug-far.nvim", setup = _109_, keys = {{mode = "n", keys = "<leader>msr", act = "<CMD>GrugFar<CR>", opts = {desc = "Replace in files"}}, {mode = "v", keys = "<leader>msw", act = _110_, opts = {desc = "Search selection"}}}}
  append_package(DEFER, s_2_auto)
  for __5_auto, args_6_auto in ipairs(s_2_auto.keys) do
    vim.keymap.set(args_6_auto.mode, args_6_auto.keys, args_6_auto.act, args_6_auto.opts)
  end
end
return init_pack()
