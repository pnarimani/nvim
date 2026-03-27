return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy  = false,  -- load at startup so FileType autocmds are registered in time
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "zig", "c_sharp", "markdown",
          "go", "gomod", "gowork", "gosum", "dart",
        },
        auto_install = true,
      })

      local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

      -- Enable treesitter-based syntax highlighting per filetype
      vim.api.nvim_create_autocmd("FileType", {
        group   = group,
        pattern = { "lua", "vim", "help", "zig", "c_sharp", "markdown",
                    "go", "gomod", "gowork", "gosum", "dart" },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
