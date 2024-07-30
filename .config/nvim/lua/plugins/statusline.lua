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
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "linrongbin16/lsp-progress.nvim",
        ---@type lsp_progress.Configs
        opts = {
          series_format = function(title, message, percentage, done)
            local postfix = ""
            if percentage ~= nil then
              postfix = string.format(" [%d%%]", percentage)
            end
            if done or percentage == 100 then
              postfix = "  "
            end

            local checked_title = title or ""
            local checked_message = message or ""

            return {
              postfix = postfix,
              message = string.format("%s %s", checked_title, checked_message),
            }
          end,
          client_format = function(client_name, spinner, series_messages)
            if #series_messages == 0 then
              return nil
            end
            return {
              spinner = spinner,
              name = client_name,
              postfix = series_messages[#series_messages].postfix,
              message = series_messages[#series_messages].message,
            }
          end,
          format = function(client_messages)
            if #client_messages == 0 then
              return ""
            end

            local message = client_messages[#client_messages]

            local max_message_length = 32
            local winwidth = vim.fn.winwidth(0)
            if winwidth ~= -1 then
              max_message_length = winwidth / 3
            end
            local abbr_message = message.message
            if abbr_message:len() > max_message_length then
              local left = abbr_message:sub(0, max_message_length / 2 - 1)
              local right = abbr_message:sub(abbr_message:len() - max_message_length / 2 - 1)
              abbr_message = left .. "..." .. right
            end

            return string.format("[%s] %s%s %s", message.name, abbr_message, message.postfix, message.spinner)
          end,
        },
        config = true,
      },
    },
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
            require("lsp-progress").progress,
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

      return opts
    end,
  },
}
