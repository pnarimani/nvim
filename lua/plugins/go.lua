return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft    = { "go", "gomod", "gowork", "gosum", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    opts  = {
      lsp_cfg      = false, -- gopls configured in lsp.lua
      lsp_gofumpt  = false, -- handled by conform.nvim
      lsp_keymaps  = false, -- our keymaps in lsp.lua
      trouble      = true,
      luasnip      = false,
      dap_debug    = true,
    },
    config = function(_, opts)
      require("go").setup(opts)

      local group = vim.api.nvim_create_augroup("GoKeymaps", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group   = group,
        pattern = "go",
        callback = function(args)
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { buffer = args.buf, desc = "Go: " .. desc })
          end
          map("<leader>gt",  "<cmd>GoTest<CR>",       "Run tests")
          map("<leader>gf",  "<cmd>GoTestFunc<CR>",   "Test function")
          map("<leader>gc",  "<cmd>GoCoverage<CR>",   "Coverage")
          map("<leader>ga",  "<cmd>GoAlt<CR>",        "Toggle test/impl")
          map("<leader>ge",  "<cmd>GoIfErr<CR>",      "Insert if err")
          map("<leader>gim", "<cmd>GoImpl<CR>",       "Implement interface")
          map("<leader>gat", "<cmd>GoAddTag<CR>",     "Add struct tags")
          map("<leader>grt", "<cmd>GoRmTag<CR>",      "Remove struct tags")
          map("<leader>gfs", "<cmd>GoFillStruct<CR>", "Fill struct")
        end,
      })
    end,
  },
}
