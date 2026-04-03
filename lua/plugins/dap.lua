if vim.g.vscode then return {} end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<F5>",        function() require("dap").continue() end,                                              desc = "Debug: Continue" },
      { "<F9>",        function() require("dap").toggle_breakpoint() end,                                     desc = "Debug: Toggle breakpoint" },
      { "<F10>",       function() require("dap").step_over() end,                                             desc = "Debug: Step over" },
      { "<F11>",       function() require("dap").step_into() end,                                             desc = "Debug: Step into" },
      { "<S-F11>",     function() require("dap").step_out() end,                                              desc = "Debug: Step out" },
      { "<leader>db",  function() require("dap").toggle_breakpoint() end,                                     desc = "Debug: Toggle breakpoint" },
      { "<leader>dB",  function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,             desc = "Debug: Conditional breakpoint" },
      { "<leader>dl",  function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log: ")) end,        desc = "Debug: Log point" },
      { "<leader>dr",  function() require("dap").repl.open() end,                                             desc = "Debug: REPL" },
      { "<leader>du",  function() require("dapui").toggle() end,                                              desc = "Debug: Toggle UI" },
      { "<leader>dt",  function() require("dap").terminate() end,                                             desc = "Debug: Terminate" },
      { "<leader>dk",  function() require("dapui").eval() end, mode = { "n", "v" },                           desc = "Debug: Eval under cursor" },
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- ── DAP UI ──────────────────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size     = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size     = 0.25,
            position = "bottom",
          },
        },
      })

      -- ── Virtual text (inline variable values) ──────────────────────────
      require("nvim-dap-virtual-text").setup({ enabled = false })

      -- ── Auto open/close UI on debug sessions ──────────────────────────
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      -- ── Breakpoint signs ───────────────────────────────────────────────
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint",            { text = "◇", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped",             { text = "→", texthl = "DiagnosticOk", linehl = "CursorLine" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "✗", texthl = "DiagnosticError" })

      -- ── mason-nvim-dap (auto-install debug adapters) ───────────────────
      require("mason-nvim-dap").setup({
        ensure_installed       = { "delve" },
        automatic_installation = true,
      })

      -- ── Go (Delve) ────────────────────────────────────────────────────
      -- On Windows: Mason creates a .cmd shim that libuv can't spawn directly.
      -- Point to the real .exe. Also pin port outside Windows reserved ranges (54875-55693).
      local mason_dlv = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv.exe"
      local system_dlv = vim.fn.expand("~/go/bin/dlv.exe")
      local dlv_path = vim.fn.filereadable(mason_dlv) == 1 and mason_dlv or system_dlv
      require("dap-go").setup({
        delve = { path = dlv_path, port = "61234" },
      })

      -- Patch the adapter so Delve's CWD is always the Go module root.
      -- Without this, Delve inherits Neovim's CWD (nvim config dir) and `go build`
      -- fails because it can't find go.mod.
      local dap = require("dap")
      local orig = dap.adapters.go
      dap.adapters.go = function(cb, config)
        local dir = vim.fn.expand("%:p:h")
        local gomod = vim.fn.findfile("go.mod", dir .. ";")
        local cwd = gomod ~= "" and vim.fn.fnamemodify(gomod, ":h") or dir
        local function patched_cb(adapter)
          if adapter.executable then
            adapter.executable.cwd = cwd
          end
          cb(adapter)
        end
        if type(orig) == "function" then
          orig(patched_cb, config)
        else
          local a = vim.deepcopy(orig)
          if a.executable then a.executable.cwd = cwd end
          cb(a)
        end
      end

      -- Replace the default "Debug" config (which uses ${file} and breaks multi-file
      -- packages) with one that uses the package directory instead.
      dap.configurations.go = vim.tbl_filter(function(c)
        return c.name ~= "Debug"
      end, dap.configurations.go or {})
      table.insert(dap.configurations.go, 1, {
        type       = "go",
        name       = "Debug",
        request    = "launch",
        program    = "${fileDirname}",
        outputMode = "remote",
      })
    end,
  },
}
