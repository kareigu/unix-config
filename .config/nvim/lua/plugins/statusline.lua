---@param name string
local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name })
end

---@param name string
---@param key "bg" | "fg" | "sp"
local function get_colour(name, key)
  return string.format("%x", get_hl(name)[key])
end

---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local colours = {
      bg = get_colour("StatusLine", "bg"),
      fg = get_colour("StatusLine", "fg"),
      inactive = get_colour("StatusLineNC", "fg"),
      bar = get_colour("MiniIconsRed", "fg"),
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
              return "▊"
            end,
            color = { fg = colours.bar }, -- Sets highlighting of component
            padding = { left = 0, right = 1 }, -- We don't need space before this
          },
          {
            function()
              return " "
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

          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " " },
            diagnostics_color = {
              error = { fg = colours.error },
              warn = { fg = colours.warn },
              info = { fg = colours.info },
            },
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
      local copy = vim.deepcopy(component)
      copy.color = { fg = colours.inactive }
      table.insert(opts.inactive_sections.lualine_c, copy)
    end

    for _, component in ipairs(opts.sections.lualine_x) do
      local copy = vim.deepcopy(component)
      copy.color = { fg = colours.inactive }
      table.insert(opts.inactive_sections.lualine_x, copy)
    end

    return opts
  end,
}
