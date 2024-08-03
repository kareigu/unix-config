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
            vim.lsp.inlay_hint.enable(true)
            map("<leader>uh", function()
              local enable = not vim.lsp.inlay_hint.is_enabled({})
              vim.lsp.inlay_hint.enable(enable)
              vim.notify("Set inlay_hint: " .. tostring(enable), vim.log.levels.INFO, {})
            end, "Toggle inlay hints")
          end
        end,
      })

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
    opts = {
      icons = {
        Text = { glyph = "󰉿", hl = "CmpItemKindText" },
        Method = { glyph = "󰆧", hl = "CmpItemKindMethod" },
        Function = { glyph = "󰊕", hl = "CmpItemKindFunction" },
        Constructor = { glyph = "", hl = "CmpItemKindConstructor" },
        Field = { glyph = "󰜢", hl = "CmpItemKindField" },
        Variable = { glyph = "󰀫", hl = "CmpItemKindVariable" },
        Class = { glyph = "󰠱", hl = "CmpItemKindClass" },
        Interface = { glyph = "", hl = "CmpItemKindInterface" },
        Module = { glyph = "", hl = "CmpItemKindModule" },
        Property = { glyph = "󰜢", hl = "CmpItemKindProperty" },
        Unit = { glyph = "󰑭", hl = "CmpItemKindUnit" },
        Value = { glyph = "󰎠", hl = "CmpitemKindValue" },
        Enum = { glyph = "", hl = "CmpItemKindEnum" },
        Keyword = { glyph = "󰌋", hl = "CmpItemKindKeyword" },
        Snippet = { glyph = "", hl = "CmpItemKindSnippet" },
        Color = { glyph = "󰏘", hl = "CmpItemKindColor" },
        File = { glyph = "󰈙", hl = "CmpItemKindFile" },
        Reference = { glyph = "󰈇", hl = "CmpItemKindReference" },
        Folder = { glyph = "󰉋", hl = "CmpItemKindFolder" },
        EnumMember = { glyph = "", hl = "CmpItemKindEnumMember" },
        Constant = { glyph = "󰏿", hl = "CmpItemKindConstant" },
        Struct = { glyph = "󰙅", hl = "CmpItemKindStruct" },
        Event = { glyph = "", hl = "CmpItemKindEvent" },
        Operator = { glyph = "󰆕", hl = "CmpItemKindOperator" },
        TypeParameter = { glyph = "", hl = "CmpItemKindTypeParameter" },
        Package = { glyph = "", hl = "CmpItemKindModule" },
        Namespace = { glyph = "", hl = "CmpItemKindModule" },
        Key = { glyph = "󰌆", hl = "CmpitemKindValue" },
        Array = { glyph = "", hl = "CmpItemKindStruct" },
        Object = { glyph = "", hl = "CmpItemKindClass" },
        Number = { glyph = "󰎠", hl = "CmpItemKindValue" },
        Boolean = { glyph = "", hl = "CmpItemKindValue" },
        String = { glyph = "", hl = "CmpItemKindValue" },
        null = { glyph = "󰟢", hl = "CmpItemKindUnit" },
      },
    },
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup({
        experimental = { ghost_text = true },
        view = {
          entries = "native",
        },
        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = opts.icons[vim_item.kind]
            if kind == nil then
              return vim_item
            end

            vim_item.menu = "(" .. vim_item.kind .. ")"
            vim_item.menu_hl_group = kind.hl
            vim_item.kind = " " .. (kind.glyph or "")
            vim_item.kind_hl_group = kind.hl
            return vim_item
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<c-n>"] = cmp.mapping.select_next_item(),
          ["<c-p>"] = cmp.mapping.select_prev_item(),
          ["<c-b>"] = cmp.mapping.scroll_docs(-4),
          ["<c-f>"] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-k>"] = cmp.mapping.complete({}),
        }),
        sources = {
          { name = "lazydev", group_index = 0 },
          { name = "nvim_lsp" },
          { name = "snippets" },
          { name = "path" },
          { name = "buffer" },
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
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
