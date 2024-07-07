local servers = {
  clangd = {},
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
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "folke/neodev.nvim", opts = {} },
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
          map("gd", require("telescope.builtin").lsp_type_definitions, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          map("<leader>cd", require("telescope.builtin").lsp_definitions, "List definitions")
          map("<leader>cR", require("telescope.builtin").lsp_references, "List references")
          map("<leader>cs", require("telescope.builtin").lsp_document_symbols, "Document symbols")
          map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cl", vim.cmd["LspInfo"], "LSP info")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
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

          vim.lsp.inlay_hint.enable(true)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>uh", function()
              local enable = not vim.lsp.inlay_hint.is_enabled({})
              vim.lsp.inlay_hint.enable(enable)
              vim.notify("Set inlay_hint: " .. tostring(enable), vim.log.levels.INFO, {})
            end, "Toggle inlay hints")
          end
        end,
      })

      require("config.utils")
      vim.lsp.handlers["$/progress"] = function(_, result, ctx)
        local client_id = ctx.client_id

        local val = result.value

        if not val.kind then
          return
        end

        local notif_data = Utils.get_notif_data(client_id, result.token)

        if val.kind == "begin" then
          local message = Utils.format_message(val.message, val.percentage)

          notif_data.notification = vim.notify(message, vim.log.levels.INFO, {
            title = Utils.format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
            icon = Utils.spinner_frames[1],
            timeout = false,
            hide_from_history = false,
          })

          notif_data.spinner = 1
          Utils.update_spinner(client_id, result.token)
        elseif val.kind == "report" and notif_data then
          notif_data.notification = vim.notify(Utils.format_message(val.message, val.percentage), vim.log.levels.INFO, {
            replace = notif_data.notification,
            hide_from_history = false,
          })
        elseif val.kind == "end" and notif_data then
          notif_data.notification = vim.notify(val.message and Utils.format_message(val.message) or "Complete", vim.log.levels.INFO, {
            icon = "",
            replace = notif_data.notification,
            timeout = 3000,
          })

          notif_data.spinner = nil
        end
      end

      -- table from lsp severity to vim severity.
      local severity = {
        "error",
        "warn",
        "info",
        "info", -- map both hint and info to info?
      }
      vim.lsp.handlers["window/showMessage"] = function(_, method, params, _)
        vim.notify(method.message, severity[params.type])
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      require("mason").setup()

      ---@type string[]
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        if server_opts.mason == true then
          ensure_installed[#ensure_installed + 1] = server
        else
          require("lspconfig")[server].setup(server_opts)
        end
      end
      vim.list_extend(ensure_installed, misc_tools)

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
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
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local disable_filetypes = {}
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        cmake = { "gersemi" },
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    version = false,
    dependencies = {
      {
        "garymjr/nvim-snippets",
        opts = { friendly_snippets = true },
      },
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      }
    end,
    keys = {
      {
        "<C-L>",
        function()
          if vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
            return
          end
          return "<C-L>"
        end,
        expr = true,
        silent = true,
        mode = "i",
        desc = "Jump to next snippet placeholder",
      },
      {
        "<C-L>",
        function()
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
        end,
        silent = true,
        mode = "s",
        desc = "Jump to next snippet placeholder",
      },
      {
        "<C-H>",
        function()
          if vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          end
          return "<C-H>"
        end,
        expr = true,
        silent = true,
        mode = { "i", "s" },
        desc = "Jump to previous snippet placeholder",
      },
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-k>"] = cmp.mapping.complete({}),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "snippets" },
          { name = "path" },
          { name = "buffer" },
        },
      })
    end,
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
