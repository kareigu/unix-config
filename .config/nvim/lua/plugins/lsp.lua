local servers = {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
  },
  rust_analyzer = {},
  zls = {},
  lua_ls = {
    mason = true,
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },
}

local misc_tools = {
  "stylua",
  "shfmt",
}

---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonUpdate",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
    keys = {
      { "<leader>cm", "<CMD>Mason<CR>", desc = "Mason" },
    },
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("krg-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc .. " (lsp)" })
          end
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gI", require("fzf-lua").lsp_implementations, "Goto implementation")
          map("<leader>cd", require("fzf-lua").lsp_definitions, "List definitions")
          map("<leader>cR", require("fzf-lua").lsp_references, "List references")
          map("<leader>cs", require("fzf-lua").lsp_document_symbols, "Document symbols")
          map("<leader>cS", require("fzf-lua").lsp_workspace_symbols, "Workspace symbols")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cl", vim.cmd["LspInfo"], "LSP info")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("krg-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("krg-lsp-detach", { clear = true }),
              callback = function(event_detach)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = "krg-lsp-highlight",
                  buffer = event_detach.buf,
                })
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
            map("<leader>uh", function()
              local enable = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
              vim.lsp.inlay_hint.enable(enable)
              vim.notify("Set inlay_hint: " .. tostring(enable), vim.log.levels.INFO, {})
            end, "Toggle inlay hints")
          end
        end,
      })

      require("mason").setup()

      ---@type string[]
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        if server_opts.mason == true then
          ensure_installed[#ensure_installed + 1] = server
        else
          server_opts.capabilities = require("blink.cmp").get_lsp_capabilities(server_opts.capabilities)
          require("lspconfig")[server].setup(server_opts)
        end
      end
      vim.list_extend(ensure_installed, misc_tools)

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = require("blink.cmp").get_lsp_capabilities(server.capabilities)
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    event = "BufWritePre",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local disable_filetypes = {}
        ---@type conform.LspFormatOpts
        local lsp_format
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format = "never"
        else
          lsp_format = "fallback"
        end

        ---@type conform.FormatOpts
        return {
          timeout_ms = 500,
          lsp_format = lsp_format,
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        cmake = { "gersemi" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "v0.*",
    dependencies = {
      {
        "garymjr/nvim-snippets",
        opts = {
          create_autocmd = true,
          create_cmp_source = false,
          friendly_snippets = true,
        },
      },
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-K>"] = { "show_documentation", "hide_documentation" },
        ["<C-L>"] = { "snippet_forward", "fallback" },
        ["<C-H>"] = { "snippet_backward", "fallback" },
        ["<Tab>"] = { "fallback" },
        ["<S-Tab>"] = { "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        sources = {
          default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = true,
        },
        signature = {
          enabled = true,
        },
      },
    },
  },
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = { { "<leader>co", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    config = true,
    opts = {
      outline_window = {
        width = 40,
        auto_close = true,
        show_numbers = true,
      },
      preview_window = {
        auto_preview = true,
      },
    },
  },
}
