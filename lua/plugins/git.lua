if vim.g.vscode then return {} end

return {
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>",            desc = "Open lazygit" },
      { "<leader>gl", "<cmd>LazyGitCurrentFile<CR>", desc = "Lazygit file log" },
    },
  },
}
