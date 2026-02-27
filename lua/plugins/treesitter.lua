return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy  = false,  -- load at startup so FileType autocmds are registered in time
    config = function()
      local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

      -- Enable treesitter-based syntax highlighting per filetype
      vim.api.nvim_create_autocmd("FileType", {
        group   = group,
        pattern = { "lua", "vim", "help", "zig", "c_sharp", "markdown" },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Use treesitter indentation for these filetypes
      vim.api.nvim_create_autocmd("FileType", {
        group   = group,
        pattern = { "lua", "zig", "c_sharp" },
        callback = function(args)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
