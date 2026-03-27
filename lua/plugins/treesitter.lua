return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy  = false,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "zig", "c_sharp", "markdown",
          "go", "gomod", "gowork", "gosum", "dart",
        },
        auto_install = true,
        highlight = { enable = true },
        indent    = { enable = true },
        textobjects = {
          select = {
            enable  = true,
            lookahead = true,
            keymaps = {
              ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
              ["af"] = { query = "@function.outer",  desc = "Around function" },
              ["if"] = { query = "@function.inner",  desc = "Inside function" },
              ["ac"] = { query = "@class.outer",     desc = "Around class" },
              ["ic"] = { query = "@class.inner",     desc = "Inside class" },
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
        },
      })
    end,
  },
}
