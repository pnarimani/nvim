if vim.g.vscode then return {} end

return {
  {
    "williamboman/mason.nvim",
    cmd   = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    opts  = {},
  },

  -- Bridges loaded as dependencies from lsp.lua and dap.lua
  {
    "williamboman/mason-lspconfig.nvim",
    lazy         = true,
    dependencies = { "williamboman/mason.nvim" },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy         = true,
    dependencies = { "williamboman/mason.nvim" },
  },
}
