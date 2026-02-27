-- Zig-specific plugins and tooling

return {
  -- Auto-format with `zig fmt` on save
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys  = {
      {
        "<leader>F",
        function() require("conform").format({ async = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        zig = { "zigfmt" },
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
        lsp_fallback = false,
      },
    },
  },

  -- Show inlay hints inline (Neovim 0.10+ native, but this adds toggle support)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts         = {},
  },
}
