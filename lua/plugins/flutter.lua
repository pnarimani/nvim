return {
  {
    "akinsho/flutter-tools.nvim",
    ft           = "dart",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      require("flutter-tools").setup({
        ui = { border = "rounded" },
        decorations = {
          statusline = { app_version = true, device = true },
        },
        widget_guides = { enabled = true },
        closing_tags = {
          enabled = true,
          prefix  = "// ",
        },
        lsp = {
          capabilities = capabilities,
          color = { enabled = true },
          settings = {
            showTodos             = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets        = true,
            updateImportsOnRename = true,
          },
          on_attach = function(_, bufnr)
            vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
          end,
        },
        debugger = {
          enabled     = true,
          run_via_dap = true,
        },
      })

      local group = vim.api.nvim_create_augroup("FlutterKeymaps", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group   = group,
        pattern = "dart",
        callback = function(args)
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { buffer = args.buf, desc = "Flutter: " .. desc })
          end
          map("<leader>Fr", "<cmd>FlutterRun<CR>",        "Run")
          map("<leader>Fh", "<cmd>FlutterHotReload<CR>",  "Hot reload")
          map("<leader>FR", "<cmd>FlutterHotRestart<CR>", "Hot restart")
          map("<leader>Fd", "<cmd>FlutterDevices<CR>",    "Devices")
          map("<leader>Fo", "<cmd>FlutterOutline<CR>",    "Outline")
          map("<leader>Fq", "<cmd>FlutterQuit<CR>",       "Quit")
          map("<leader>Fl", "<cmd>FlutterLspRestart<CR>", "LSP restart")
        end,
      })
    end,
  },
}
