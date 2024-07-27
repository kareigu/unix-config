---@type LazySpec
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  ft = {},
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      handlers = {},
      ensure_installed = {},
    })

    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/Continue (debug)" })
    vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Step Into (debug)" })
    vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Step Over (debug)" })
    vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Step Out (debug)" })
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint (debug)" })
    vim.keymap.set("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Set Breakpoint (debug)" })

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })

    vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "See last session result (debug)" })
    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    require("config.utils")
    dap.listeners.before["event_progressStart"]["progress-notifications"] = function(session, body)
      local notif_data = Utils.get_notif_data("dap", body.progressId)

      local message = Utils.format_message(body.message, body.percentage)
      notif_data.notification = vim.notify(message, vim.log.levels.INFO, {
        title = Utils.format_title(body.title, session.config.type),
        icon = Utils.spinner_frames[1],
        timeout = false,
        hide_from_history = false,
      })

      notif_data.notification.spinner = 1
      Utils.update_spinner("dap", body.progressId)
    end

    dap.listeners.before["event_progressUpdate"]["progress-notifications"] = function(session, body)
      local notif_data = Utils.get_notif_data("dap", body.progressId)
      notif_data.notification = vim.notify(Utils.format_message(body.message, body.percentage), vim.log.levels.INFO, {
        replace = notif_data.notification,
        hide_from_history = false,
      })
    end

    dap.listeners.before["event_progressEnd"]["progress-notifications"] = function(session, body)
      local notif_data = Utils.client_notifs["dap"][body.progressId]
      notif_data.notification = vim.notify(body.message and Utils.format_message(body.message) or "Complete", vim.log.levels.INFO, {
        icon = "",
        replace = notif_data.notification,
        timeout = 3000,
      })
      notif_data.spinner = nil
    end
  end,
}
