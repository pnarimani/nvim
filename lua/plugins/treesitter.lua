return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build  = ":TSUpdate",
    lazy   = false,
    config = function()
      require("nvim-treesitter").setup({})

      -- Install parsers (async, non-blocking)
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "zig", "c_sharp", "markdown",
        "go", "gomod", "gowork", "gosum", "dart",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch       = "main",
    lazy         = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ts_to = require("nvim-treesitter-textobjects")
      ts_to.setup({
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
          sel.select_textobject(query, "textobjects")
        end, { desc = desc })
      end

      -- Jump to next/previous function or class
      vim.keymap.set("n", "]f", function() move.goto_next_start("@function.outer", "textobjects") end,     { desc = "Next function start" })
      vim.keymap.set("n", "]F", function() move.goto_next_end("@function.outer", "textobjects") end,       { desc = "Next function end" })
      vim.keymap.set("n", "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
      vim.keymap.set("n", "[F", function() move.goto_previous_end("@function.outer", "textobjects") end,   { desc = "Prev function end" })
      vim.keymap.set("n", "]c", function() move.goto_next_start("@class.outer", "textobjects") end,        { desc = "Next class start" })
      vim.keymap.set("n", "]C", function() move.goto_next_end("@class.outer", "textobjects") end,          { desc = "Next class end" })
      vim.keymap.set("n", "[c", function() move.goto_previous_start("@class.outer", "textobjects") end,    { desc = "Prev class start" })
      vim.keymap.set("n", "[C", function() move.goto_previous_end("@class.outer", "textobjects") end,      { desc = "Prev class end" })
    end,
  },
}
