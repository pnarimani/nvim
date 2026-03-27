return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
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
      })

      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move   = { set_jumps = true },
      })

      local sel  = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- Text objects (visual + operator-pending)
      local textobjects = {
        ["aa"] = { "@parameter.outer", "Around argument" },
        ["ia"] = { "@parameter.inner", "Inside argument" },
        ["af"] = { "@function.outer",  "Around function" },
        ["if"] = { "@function.inner",  "Inside function" },
        ["ac"] = { "@class.outer",     "Around class" },
        ["ic"] = { "@class.inner",     "Inside class" },
      }
      for key, def in pairs(textobjects) do
        local query, desc = def[1], def[2]
        vim.keymap.set({ "x", "o" }, key, function()
          sel.select_textobject(query)
        end, { desc = desc })
      end

      -- Jump to next/previous function or class
      vim.keymap.set("n", "]f", function() move.goto_next_start("@function.outer") end,     { desc = "Next function start" })
      vim.keymap.set("n", "]F", function() move.goto_next_end("@function.outer") end,       { desc = "Next function end" })
      vim.keymap.set("n", "[f", function() move.goto_previous_start("@function.outer") end, { desc = "Prev function start" })
      vim.keymap.set("n", "[F", function() move.goto_previous_end("@function.outer") end,   { desc = "Prev function end" })
      vim.keymap.set("n", "]c", function() move.goto_next_start("@class.outer") end,        { desc = "Next class start" })
      vim.keymap.set("n", "]C", function() move.goto_next_end("@class.outer") end,          { desc = "Next class end" })
      vim.keymap.set("n", "[c", function() move.goto_previous_start("@class.outer") end,    { desc = "Prev class start" })
      vim.keymap.set("n", "[C", function() move.goto_previous_end("@class.outer") end,      { desc = "Prev class end" })
    end,
  },
}
