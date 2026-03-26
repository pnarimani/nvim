return {
  -- LSP progress / status indicator (shown in the corner while ZLS indexes)
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts  = {
      notification = { window = { winblend = 0 } },
    },
  },

  -- Provides server definitions (cmd, filetypes, root_markers) via lsp/ runtime dir.
  -- We use vim.lsp.config / vim.lsp.enable (nvim 0.11 API) instead of require('lspconfig').
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = { "j-hui/fidget.nvim", "williamboman/mason-lspconfig.nvim" },
    config       = function()
      -- Merge nvim-cmp advertised capabilities into every server
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Apply capabilities globally to all enabled servers
      vim.lsp.config("*", { capabilities = capabilities })

      -- Ensure LSP servers are installed via mason
      require("mason-lspconfig").setup({
        ensure_installed  = { "gopls", "zls" },
        automatic_enable  = false, -- we call vim.lsp.enable() explicitly below
      })

      -- ── Zig ──────────────────────────────────────────────────────────────
      vim.lsp.config("zls", {
        settings = {
          zls = {
            enable_inlay_hints                     = true,
            inlay_hints_show_builtin               = true,
            inlay_hints_exclude_single_argument    = true,
            inlay_hints_hide_redundant_param_names = true,
            enable_snippets                        = true,
            warn_style                             = true,
            enable_ast_check_diagnostics           = true,
            enable_autofix                         = true,
          },
        },
      })
      vim.lsp.enable("zls")

      -- ── Go ───────────────────────────────────────────────────────────────
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt            = true,
            staticcheck        = true,
            usePlaceholders    = true,
            completeUnimported = true,
            analyses = {
              unusedparams = true,
              shadow       = true,
              nilness      = true,
              unusedwrite  = true,
            },
            hints = {
              assignVariableTypes    = true,
              compositeLiteralFields = true,
              constantValues         = true,
              functionTypeParameters = true,
              parameterNames         = true,
              rangeVariableTypes     = true,
            },
          },
        },
      })
      vim.lsp.enable("gopls")

      -- Buffer-local keymaps set once per attach (replaces on_attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local nmap = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          local nvmap = function(keys, fn, desc)
            vim.keymap.set({ "n", "x" }, keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          -- Navigation (matches ideavimrc: gd, gi, gr, gD; <C-o>/<C-i> are built-in)
          nmap("gd",  vim.lsp.buf.definition,      "Go to definition")
          nmap("gD",  vim.lsp.buf.type_definition, "Go to type definition")  -- ideavimrc: GotoTypeDeclaration
          nmap("gr",  vim.lsp.buf.references,      "Show usages")            -- ideavimrc: ShowUsages
          nmap("gi",  vim.lsp.buf.implementation,  "Go to implementation")   -- ideavimrc: GotoImplementation
          nmap("K",   vim.lsp.buf.hover,           "Hover docs")

          -- Refactoring (matches ideavimrc: <leader>rn, <leader>f, <leader>re, <leader>rr)
          nmap("<leader>rn",  vim.lsp.buf.rename,                                  "Rename symbol")
          nmap("<leader>f",   function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          nvmap("<leader>re", vim.lsp.buf.code_action, "Intention actions")        -- ideavimrc: ShowIntentionActions
          nvmap("<leader>rr", vim.lsp.buf.code_action, "Refactoring actions")      -- ideavimrc: Refactorings.QuickListPopupAction
          nmap("<leader>ca",  vim.lsp.buf.code_action, "Code action")              -- nvim extra

          -- Find usages (ideavimrc: <leader>gr → FindUsages)
          nmap("<leader>gr", function()
            require("telescope.builtin").lsp_references()
          end, "Find usages")
        end,
      })
    end,
  },
}

