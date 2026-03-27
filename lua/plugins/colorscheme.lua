return {
  {
    "rebelot/kanagawa.nvim",
    lazy     = false,  -- must load at startup to set colors before other UI
    priority = 1000,
    opts     = {
      theme = "dragon",
    },
    config   = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa-dragon")
    end,
  },
}
