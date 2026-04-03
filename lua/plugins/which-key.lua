if vim.g.vscode then return {} end

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>?", "<cmd>WhichKey<CR>", desc = "Show keymaps" },
    },
    opts = {},
  },
}
