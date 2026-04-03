if vim.g.vscode then return {} end

-- Formatters and rendering (multi-language)

return {
  -- Auto-format on save via conform.nvim
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        zig  = { "zigfmt" },
        go   = { "goimports", "gofumpt" },
        dart = { "dart_format" },
      },
      formatters = {
        zigfmt = {
          command = "zig",
          args    = { "fmt", "--stdin" },
          stdin   = true,
        },
      },
      format_on_save = {
        timeout_ms   = 500,
        lsp_format = "never",
      },
    },
  },

  -- Rendered markdown preview
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts         = {},
  },
}
