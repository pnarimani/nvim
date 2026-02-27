return {
  {
    "folke/tokyonight.nvim",
    lazy     = false,  -- must load at startup to set colors before other UI
    priority = 1000,
    opts     = { style = "moon" },
    config   = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
