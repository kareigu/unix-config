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

if vim.uv.os_uname().sysname == "Darwin" and vim.fn.executable("ghostty") == 1 then
    vim.opt.rtp:prepend("/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/")
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
    { "n", "<leader>cc", "<cmd>Compile<cr>", { desc = "Compile" } },
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

map({
    { "n", "<leader>ll", "<cmd>ListPackages<cr>", { desc = "List packages" } },
    {
        "n",
        "<leader>lu",
        function()
            vim.pack.update()
        end,
        { desc = "Update packages" },
    },
})

-- END KEYS

-- COMMANDS
vim.api.nvim_create_user_command("OpenConfig", function()
    vim.fn.chdir(vim.fn.stdpath("config"))
    vim.cmd.edit("$MYVIMRC")
end, {})

vim.api.nvim_create_user_command("ListPackages", function()
    local packages = vim.pack.get()

    local lines = {}

    if #packages == 0 then
        lines = { "No packages installed" }
    else
        for _, package in ipairs(packages) do
            local active_str = " "
            if not package.active then
                active_str = " "
            end
            local title = string.format("%s - %s", package.spec.name, active_str)
            local src = string.format("\tsrc = %s", package.spec.src)
            local rev = string.format("\trev = %s", package.rev)
            local path = string.format("\tpath = %s", package.path)
            table.insert(lines, title)
            table.insert(lines, src)
            table.insert(lines, rev)
            table.insert(lines, path)
            table.insert(lines, "")
        end
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        border = "rounded",
        width = vim.o.columns - 6,
        height = vim.o.lines - 6,
        col = 2,
        row = 2,
        style = "minimal",
    })

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

    local ns = vim.api.nvim_create_namespace("pkg_hl")
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    for i, package in ipairs(packages) do
        local line = (i - 1) * 5
        local header_len = #lines[line + 1] - 6
        vim.api.nvim_buf_add_highlight(bufnr, ns, "Title", line, 0, header_len)
        local icon_colour = "DiagnosticOk"
        if not package.active then
            icon_colour = "DiagnosticError"
        end
        vim.api.nvim_buf_add_highlight(bufnr, ns, icon_colour, line, header_len + 1, -1)
        vim.api.nvim_buf_add_highlight(bufnr, ns, "Special", line + 1, 0, -1)
        vim.api.nvim_buf_add_highlight(bufnr, ns, "Number", line + 2, 0, -1)
        vim.api.nvim_buf_add_highlight(bufnr, ns, "Directory", line + 3, 0, -1)
    end

    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false
    vim.bo[bufnr].bufhidden = "wipe"
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, nowait = true })
    vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = bufnr })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = bufnr })
    vim.api.nvim_create_autocmd("BufLeave", {
        desc = "Close pack info on buffer closure",
        buffer = bufnr,
        once = true,
        nested = true,
        callback = function()
            if vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_win_close(winid, true)
            end
        end,
    })

    vim.bo[bufnr].filetype = "pack-info"
end, {})

vim.api.nvim_create_user_command("Compile", function(opts)
    if vim.g.krg_compile_last_command == nil then
        vim.g.krg_compile_last_command = "cd build && ninja"
    end
    local function handle_compile(input)
        local bufnr = vim.api.nvim_create_buf(false, true)
        local winid = vim.api.nvim_open_win(bufnr, true, {
            relative = "editor",
            border = "rounded",
            width = vim.o.columns - 6,
            height = vim.o.lines - 6,
            col = 2,
            row = 2,
            style = "minimal",
        })

        local function handle_output(err, data)
            if err ~= nil then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end

            if data == nil then
                return
            end

            vim.schedule(function()
                if not vim.api.nvim_win_is_valid(winid) then
                    return
                end

                local ansi_stripped = data:gsub("\x1b%[[%d;]*[a-zA-Z]", "")
                local lines = vim.split(ansi_stripped, "\n", { trimempty = true })
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, lines)
            end)
        end

        local obj = vim.system({ "sh", "-c", input }, {
            text = true,
            stdout = handle_output,
            stderr = handle_output,
        }, function(obj)
            if obj ~= nil then
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, { string.format("-- exited with code %d --", obj.code) })
                    vim.bo[bufnr].modifiable = false
                end)
            end
        end)
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, true, { string.format("-- running: %s --", input) })

        vim.bo[bufnr].modified = false
        vim.bo[bufnr].bufhidden = "wipe"
        map({
            { "n", "q", "<cmd>close<cr>", { buffer = bufnr, nowait = true } },
            { "n", "<C-c>", "<cmd>close<cr>", { buffer = bufnr } },
            { "n", "<Esc>", "<cmd>close<cr>", { buffer = bufnr } },
            {
                "n",
                "o",
                function()
                    if not vim.api.nvim_win_is_valid(winid) then
                        return
                    end
                    vim.api.nvim_win_set_config(winid, {
                        split = "right",
                        win = vim.fn.win_getid(vim.fn.winnr("#")),
                    })
                end,
                { buffer = bufnr },
            },
        })
        vim.api.nvim_create_autocmd("BufDelete", {
            desc = "Close compilation window on buffer close",
            buffer = bufnr,
            once = true,
            nested = true,
            callback = function()
                if not obj:is_closing() then
                    obj:kill("SIGTERM")
                end
                if vim.api.nvim_win_is_valid(winid) then
                    vim.api.nvim_win_close(winid, true)
                end
            end,
        })

        vim.bo[bufnr].filetype = "compilation"
    end

    if #opts.args > 0 then
        handle_compile(opts.args)
    else
        vim.ui.input({
            prompt = "Compile: ",
            default = vim.g.krg_compile_last_command,
            completion = "shellcmdline",
        }, function(input)
            if input == nil then
                return
            end
            if #input == 0 then
                vim.g.krg_compile_last_command = nil
                vim.notify("Empty command not allowed", vim.log.levels.ERROR)
                return
            end
            vim.g.krg_compile_last_command = input
            handle_compile(input)
        end)
    end
end, {
    desc = "Run compilation command and display the output in a buffer",
    complete = "shellcmdline",
    nargs = "*",
})

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

--
-- PACKAGES
--

local INSTANT = 1
local DEFER = 2
local packages_to_install = {}
local on_update_hooks = {}

local function append_package(load_time, spec)
    if packages_to_install[load_time] == nil then
        packages_to_install[load_time] = {
            urls = { spec[1] },
            setups = { spec.setup },
            deps = { spec.deps or {} },
        }
        return
    end

    local len = #packages_to_install[load_time]["urls"]
    packages_to_install[load_time]["urls"][len + 1] = spec[1]
    packages_to_install[load_time]["setups"][len + 1] = spec.setup or false
    packages_to_install[load_time]["deps"][len + 1] = spec.deps or {}
end

local function use_pack(spec)
    if spec.instant ~= nil and spec.instant then
        append_package(INSTANT, spec)
    elseif spec.event ~= nil then
        append_package(spec.event, spec)
    else
        append_package(DEFER, spec)
    end

    if spec.init ~= nil then
        spec.init()
    end

    if spec.keys ~= nil then
        map(spec.keys)
    end

    if spec.on_update ~= nil then
        table.insert(on_update_hooks, { spec[1], spec.on_update })
    end
end

local function init_pack()
    local function add_and_setup(specs)
        vim.pack.add(specs.urls)
        for _, setup in ipairs(specs.setups) do
            if setup ~= false then
                setup()
            end
        end
        for _, deps in ipairs(specs.deps) do
            vim.pack.add(deps)
        end
    end

    for load_time, specs in pairs(packages_to_install) do
        if load_time == INSTANT then
            add_and_setup(specs)
        elseif load_time == DEFER then
            vim.schedule(function()
                add_and_setup(specs)
            end)
        else
            vim.api.nvim_create_autocmd(load_time, {
                once = true,
                callback = function()
                    add_and_setup(specs)
                end,
            })
        end
    end

    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            if ev.data.kind ~= "update" then
                return
            end

            local spec = vim.pack.get({ ev.data.spec.name })

            for _, hook in ipairs(on_update_hooks) do
                if hook[1] == ev.data.spec.src then
                    if not ev.data.active then
                        vim.cmd.packadd(ev.data.spec.name)
                    end
                    vim.cmd(hook[2])
                end
            end
        end,
    })
end

use_pack({
    "https://github.com/rebelot/kanagawa.nvim",
    instant = true,
    on_update = "KanagawaCompile",
    setup = function()
        require("kanagawa").setup({
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
                }
            end,
        })
        vim.cmd.colorscheme("kanagawa")
    end,
})

use_pack({
    "https://github.com/stevearc/conform.nvim",
    setup = function()
        local ft_formatters = {
            lua = { "stylua" },
            cmake = { "gersemi" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            zig = { "zigfmt" },
            toml = { "taplo" },
            rust = { "rustfmt" },
            odin = { "odinfmt" },
        }

        local formatters = {
            odinfmt = {
                command = "odinfmt",
                args = { "-stdin" },
            },
        }

        local ok, local_fmt = pcall(require, "local_fmt")
        if ok then
            if local_fmt.ft_formatters ~= nil then
                ft_formatters = vim.tbl_deep_extend("force", ft_formatters, local_fmt.ft_formatters)
            end
            if local_fmt.formatters ~= nil then
                formatters = vim.tbl_deep_extend("force", formatters, local_fmt.formatters)
            end
        else
            vim.notify("error loading local_fmt")
        end

        require("conform").setup({
            notify_on_error = true,
            formatters_by_ft = ft_formatters,
            formatters = formatters,
        })
    end,
    keys = {
        {
            "n",
            "<leader>cf",
            function()
                require("conform").format({ async = true })
            end,
            { desc = "Format buffer" },
        },
        {
            { "x", "v" },
            "<leader>cf",
            function()
                require("conform").format({ async = true })
            end,
            { desc = "Format selection" },
        },
        { "n", "<leader>ci", "<cmd>ConformInfo<cr>", { desc = "Formatter info" } },
    },
})

use_pack({
    "https://github.com/folke/which-key.nvim",
    setup = function()
        require("which-key").setup({
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
                { "<leader>l", icon = " ", group = "packages" },
                { "<leader>y", '"+y', icon = " ", desc = "Copy to clipboard", mode = { "n", "x", "v", "t" } },
                { "<leader>Y", '"+Y', icon = " ", desc = "Copy line to clipboard" },
                { "<leader>p", '"+p', icon = " ", desc = "Paste from clipboard after selection" },
                { "<leader>P", '"+P', icon = " ", desc = "Paste from clipboard before selection" },
                {
                    mode = { "v" },
                    { "<leader>g", group = "git hunk" },
                },
            },
        })
    end,
})

use_pack({
    "https://github.com/nvim-lualine/lualine.nvim",
    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            vim.o.statusline = " "
        else
            vim.o.laststatus = 0
        end
    end,
    setup = function()
        local function get_hl(name)
            return vim.api.nvim_get_hl(0, { name = name })
        end

        local function get_colour(name, key)
            return string.format("%x", get_hl(name)[key])
        end

        local colours = {
            bg = get_colour("StatusLine", "bg"),
            fg = get_colour("StatusLine", "fg"),
            inactive = get_colour("StatusLineNC", "fg"),
            filepath = get_colour("MiniStatuslineFilename", "fg"),
            fileinfo = get_colour("MiniStatuslineFileinfo", "fg"),
            vcs = get_colour("SpecialKey", "fg"),
            error = get_colour("DiagnosticError", "fg"),
            warn = get_colour("DiagnosticWarn", "fg"),
            info = get_colour("DiagnosticInfo", "fg"),
            mode = {
                normal = get_colour("MiniStatuslineModeNormal", "bg"),
                insert = get_colour("MiniStatuslineModeInsert", "bg"),
                visual = get_colour("MiniStatuslineModeVisual", "bg"),
                replace = get_colour("MiniStatuslineModeReplace", "bg"),
                command = get_colour("MiniStatuslineModeCommand", "bg"),
                other = get_colour("MiniStatuslineModeOther", "bg"),
            },
        }

        local conditions = {
            buffer_not_empty = function()
                return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
            end,
            check_git_workspace = function()
                local filepath = vim.fn.expand("%:p:h")
                local gitdir = vim.fn.finddir(".git", filepath .. ";")
                return gitdir and #gitdir > 0 and #gitdir < #filepath
            end,
        }

        local opts = {
            options = {
                component_separators = "",
                section_separators = "",
                theme = {
                    normal = { c = { fg = colours.fg, bg = colours.bg } },
                    inactive = { c = { fg = colours.fg, bg = colours.bg } },
                },
                global_status = vim.o.laststatus == 3,
                disabled_filetypes = { statusline = { "dashboard" } },
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_y = {},
                lualine_z = {},
                lualine_c = {
                    {
                        function()
                            return "  "
                        end,
                        color = function()
                            local mode_color = {
                                n = colours.mode.normal,
                                i = colours.mode.insert,
                                v = colours.mode.visual,
                                [""] = colours.mode.visual,
                                V = colours.mode.visual,
                                c = colours.mode.command,
                                no = colours.mode.normal,
                                s = colours.mode.other,
                                S = colours.mode.other,
                                [""] = colours.mode.other,
                                ic = colours.mode.other,
                                R = colours.mode.replace,
                                Rv = colours.mode.replace,
                                cv = colours.mode.other,
                                ce = colours.mode.other,
                                r = colours.mode.replace,
                                rm = colours.mode.replace,
                                ["r?"] = colours.mode.replace,
                                ["!"] = colours.mode.command,
                                t = colours.mode.command,
                            }
                            return { fg = mode_color[vim.fn.mode()] }
                        end,
                        padding = { right = 1 },
                    },
                    {
                        "filesize",
                        cond = conditions.buffer_not_empty,
                    },
                    {
                        "filename",
                        cond = conditions.buffer_not_empty,
                        color = { fg = colours.filepath, gui = "bold" },
                        newfile_status = true,
                        path = 1,
                    },
                    { "location" },
                    { "progress", color = { fg = colours.fg, gui = "bold" } },
                },
                lualine_x = {
                    {
                        "o:encoding",
                        fmt = string.upper,
                        color = { fg = colours.fileinfo, gui = "bold" },
                    },
                    {
                        "fileformat",
                        fmt = string.upper,
                        icons_enabled = false,
                        color = { fg = colours.fileinfo, gui = "bold" },
                    },
                    {
                        "branch",
                        icon = "",
                        color = { fg = colours.vcs, gui = "bold" },
                    },

                    {
                        "filetype",
                        icons_enabled = true,
                        color = { fg = colours.fileinfo, gui = "bold" },
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_y = {},
                lualine_z = {},
                lualine_c = {},
                lualine_x = {},
            },
        }

        for _, component in ipairs(opts.sections.lualine_c) do
            if type(component) ~= "table" then
                goto continue
            end
            local copy = vim.deepcopy(component)
            copy.color = { fg = colours.inactive }
            table.insert(opts.inactive_sections.lualine_c, copy)
            ::continue::
        end

        for _, component in ipairs(opts.sections.lualine_x) do
            if type(component) ~= "table" then
                goto continue
            end
            local copy = vim.deepcopy(component)
            copy.color = { fg = colours.inactive }
            table.insert(opts.inactive_sections.lualine_x, copy)
            ::continue::
        end

        require("lualine").setup(opts)
    end,
})

use_pack({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    instant = true,
    on_update = "TSUpdate",
    setup = function()
        local ensure_installed = {
            "bash",
            "c",
            "cpp",
            "diff",
            "html",
            "lua",
            "luadoc",
            "rust",
            "toml",
            "vim",
            "vimdoc",
            "yaml",
            "zig",
        }
        require("nvim-treesitter").install(ensure_installed)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = require("nvim-treesitter").get_installed(),
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
})

use_pack({
    "https://github.com/folke/todo-comments.nvim",
    event = "BufReadPost",
    deps = { "https://github.com/nvim-lua/plenary.nvim" },
    setup = function()
        require("todo-comments").setup({ signs = false })
    end,
})

use_pack({ "https://github.com/nvim-tree/nvim-web-devicons" })
use_pack({
    "https://github.com/rcarriga/nvim-notify",
    event = "VimEnter",
    setup = function()
        require("notify").setup({ render = "compact" })
        vim.notify = require("notify")
    end,
})
use_pack({
    "https://github.com/ojroques/nvim-bufdel",
    setup = function()
        require("bufdel").setup({
            quit = false,
        })
    end,
    keys = {
        { "n", "<leader>bd", "<cmd>BufDel<cr>", { desc = "Close current buffer" } },
        { "n", "<leader>bD", "<cmd>BufDel!<cr>", { desc = "Force close current buffer" } },
        { "n", "<leader>bo", "<cmd>BufDelOthers<cr>", { desc = "Close all other buffers" } },
        { "n", "<leader>bO", "<cmd>BufDelOthers!<cr>", { desc = "Force close all other buffers" } },
        { "n", "<leader>bA", "<cmd>BufDelAll!<cr>", { desc = "Force close all buffers" } },
    },
})

use_pack({
    "https://github.com/ibhagwan/fzf-lua",
    setup = function()
        require("fzf-lua").setup({ "ivy" })
    end,
    keys = {
        { "n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Search files" } },
        {
            "n",
            "<leader>.",
            function()
                require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
            end,
            { desc = "Search files (cwd)" },
        },
        { "n", "<leader>sh", "<cmd>FzfLua helptags<cr>", { desc = "Search help" } },
        { "n", "<leader>sm", "<cmd>FzfLua manpages<cr>", { desc = "Search manpages" } },
        { "n", '<leader>s"', "<cmd>FzfLua registers<cr>", { desc = "Search registers" } },
        { "n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Search keymaps" } },
        { "n", "<leader>ss", "<cmd>FzfLua<cr>", { desc = "Search select" } },
        { "n", "<leader>sj", "<cmd>FzfLua jumps<cr>", { desc = "Search jumplist" } },
        { "n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Search current word" } },
        { "n", "<leader>sg", "<cmd>FzfLua live_grep_native<cr>", { desc = "Search by grep" } },
        {
            "n",
            "<leader>sG",
            function()
                require("fzf-lua").live_grep_native({ cwd = vim.fn.expand("%:p:h") })
            end,
            { desc = "Search by grep (cwd)" },
        },
        { "n", "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Search diagnostics" } },
        { "n", "<leader>sr", "<cmd>FzfLua resume<cr>", { desc = "Search resume" } },
        { "n", "<leader>bs", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" } },
        { "n", "<leader>/", "<cmd>FzfLua blines<cr>", { desc = "Search in current buffer" } },
        { "n", "<leader>s/", "<cmd>FzfLua lines<cr>", { desc = "Search in open files" } },
        {
            "n",
            "<leader>sc",
            function()
                require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
            end,
            { desc = "Search config files" },
        },
    },
})

use_pack({
    "https://github.com/nvim-mini/mini.surround",
    setup = function()
        require("mini.surround").setup({
            mappings = {
                add = "ys",
                delete = "ds",
                replace = "cs",
                highlight = "sh",
                find = "sf",
                find_left = "sF",
                update_lines = "sn",
                suffix_last = "",
                suffix_next = "",
            },
            search_method = "cover_or_next",
            custom_surroundings = {
                ["B"] = { output = { left = "{", right = "}" } },
            },
        })
    end,
    keys = {
        { "x", "S", "ys", { desc = "surround selection", remap = true } },
        { "n", "yss", "ys_", { desc = "surround line", remap = true } },
    },
})

use_pack({
    "https://github.com/lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNew" },
    keys = {
        { "n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Search commits" } },
        { "n", "<leader>gB", "<cmd>FzfLua git_branches<CR>", { desc = "Search branches" } },
        { "n", "<leader>gf", "<cmd>FzfLua git_files<CR>", { desc = "Search files" } },
    },
    setup = function()
        require("gitsigns").setup({
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
        })
    end,
})

use_pack({
    "https://github.com/folke/persistence.nvim",
    setup = function()
        require("persistence").setup({ options = vim.opt.sessionoptions:get() })
    end,
    keys = {
        {
            "n",
            "<leader>qr",
            function()
                require("persistence").load()
                vim.notify("CWD session loaded", vim.log.levels.INFO)
            end,
            { desc = "Load session for current directory" },
        },
        {
            "n",
            "<leader>ql",
            function()
                require("persistence").load({ last = true })
                vim.notify("Last session loaded", vim.log.levels.INFO)
            end,
            { desc = "Load last session" },
        },
        {
            "n",
            "<leader>qd",
            function()
                require("persistence").stop()
                vim.notify("Disabled automatically saving session", vim.log.levels.INFO)
            end,
            { desc = "Don't automatically save current session" },
        },
        {
            "n",
            "<leader>qD",
            function()
                require("persistence").start()
                vim.notify("Automatically saving session", vim.log.levels.INFO)
            end,
            { desc = "Automatically save current session" },
        },
        {
            "n",
            "<leader>qs",
            function()
                require("persistence").save()
                vim.notify("Saved session", vim.log.levels.INFO)
            end,
            { desc = "Save current session" },
        },
    },
})

use_pack({
    "https://github.com/MagicDuck/grug-far.nvim",
    setup = function()
        require("grug-far").setup({ transient = true })
    end,
    keys = {
        {
            "n",
            "<leader>msr",
            "<CMD>GrugFar<CR>",
            { desc = "Replace in files" },
        },
        {
            "v",
            "<leader>msw",
            function()
                require("grug-far").with_visual_selection()
            end,
            { desc = "Search selection" },
        },
    },
})

init_pack()
--
-- END PACKAGES
--
