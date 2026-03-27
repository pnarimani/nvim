local function split_rgb(color)
  return math.floor(color / 0x10000), math.floor(color / 0x100) % 0x100, color % 0x100
end

local function compose_rgb(r, g, b)
  return r * 0x10000 + g * 0x100 + b
end

local function blend_colors(base, accent, ratio)
  local base_r, base_g, base_b = split_rgb(base)
  local accent_r, accent_g, accent_b = split_rgb(accent)

  local blend_channel = function(base_channel, accent_channel)
    return math.floor((base_channel * (1 - ratio)) + (accent_channel * ratio) + 0.5)
  end

  return compose_rgb(
    blend_channel(base_r, accent_r),
    blend_channel(base_g, accent_g),
    blend_channel(base_b, accent_b)
  )
end

local function apply_reference_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
  local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })

  local base_bg = normal.bg or 0x1f2335
  local accent_bg = cursorline.bg or visual.bg or 0x2a2f44
  local subtle_bg = blend_colors(base_bg, accent_bg, 0.35)

  for _, group in ipairs({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite" }) do
    vim.api.nvim_set_hl(0, group, { bg = subtle_bg })
  end
end

local function make_lsp_reference_entry(entry)
  local make_entry = require("telescope.make_entry")
  local filename = entry.filename
  if not filename or filename == "" then
    local bufnr = type(entry.bufnr) == "number" and entry.bufnr or nil
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      filename = vim.api.nvim_buf_get_name(bufnr)
    else
      filename = "[No Name]"
    end
  end
  local basename = vim.fs.basename(filename)

  return make_entry.set_default_entry_mt({
    value = entry,
    ordinal = table.concat({ filename, basename, tostring(entry.lnum), entry.text or "" }, " "),
    display = function() return string.format("%s:%d", basename, entry.lnum) end,
    bufnr = entry.bufnr,
    filename = filename,
    lnum = entry.lnum,
    col = entry.col,
    text = entry.text,
    start = entry.start,
    finish = entry.finish,
  }, {})
end

local function telescope_lsp_references()
  require("telescope.builtin").lsp_references({
    show_line = false,
    entry_maker = make_lsp_reference_entry,
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.72,
    },
  })
end

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
      apply_reference_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("UserLspReferenceHighlights", { clear = true }),
        callback = apply_reference_highlights,
      })

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
          },
        },
      })
      vim.lsp.enable("gopls")

      -- Buffer-local keymaps set once per attach (replaces on_attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local nmap = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          local nvmap = function(keys, fn, desc)
            vim.keymap.set({ "n", "x" }, keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          local builtin = require("telescope.builtin")

          -- Navigation via Telescope (fuzzy + preview)
          nmap("gd",  builtin.lsp_definitions,      "Go to definition")
          nmap("gD",  builtin.lsp_type_definitions,  "Go to type definition")
          nmap("gr",  telescope_lsp_references,      "Show usages")
          nmap("gi",  builtin.lsp_implementations,   "Go to implementation")
          nmap("K",   vim.lsp.buf.hover,             "Hover docs")

          -- Refactoring
          nmap("<leader>rn", vim.lsp.buf.rename,                                  "Rename symbol")
          nmap("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          nvmap("<leader>re", vim.lsp.buf.code_action, "Code action")

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local group = vim.api.nvim_create_augroup("UserLspDocumentHighlight" .. bufnr, { clear = true })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = group,
              buffer = bufnr,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "LspDetach" }, {
              group = group,
              buffer = bufnr,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },
}
