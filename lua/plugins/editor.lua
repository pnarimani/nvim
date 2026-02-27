return {
  -- Fuzzy finder over files, grep, buffers
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- <leader>sf → GotoClass equivalent (find files)
      { "<leader>sf", function() require("telescope.builtin").find_files() end,                         desc = "Find files" },
      -- <leader>ss → GotoSymbol (workspace symbols)
      { "<leader>ss", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,     desc = "Workspace symbols" },
      -- <leader>sd → FileStructurePopup (document symbols)
      { "<leader>sd", function() require("telescope.builtin").lsp_document_symbols() end,              desc = "Document symbols" },
      -- <leader>sg → live grep (text search, no direct ideavimrc equivalent but essential)
      { "<leader>sg", function() require("telescope.builtin").live_grep() end,                          desc = "Live grep" },
    },
    opts = {
      defaults = {
        prompt_prefix    = "> ",
        selection_caret  = "> ",
        sorting_strategy = "ascending",
        layout_config    = { prompt_position = "top" },
      },
    },
  },

  -- Git change indicators in the sign column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "^" },
        changedelete = { text = "~" },
      },
      update_debounce    = 100,
      attach_to_untracked = false,
    },
  },

  -- Visualise and navigate the undo tree
  {
    "mbbill/undotree",
    cmd  = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undotree" } },
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth         = 40
      vim.g.undotree_WindowLayout       = 2
    end,
  },

  -- Surround text objects with brackets, quotes, tags …
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts  = {},
  },

  -- gc / gcc to comment lines and motions
  {
    "numToStr/Comment.nvim",
    keys = { "gc", "gcc" },
    opts = {},
  },

  -- Briefly highlight the yanked region
  {
    "machakann/vim-highlightedyank",
    event = "TextYankPost",
  },

  -- Highlight unique characters for f/t motions
  {
    "unblevable/quick-scope",
    event = "VeryLazy",
    init  = function()
      vim.g.qs_accepted_chars = {
        "a","b","c","d","e","f","g","h","i","j","k","l","m",
        "n","o","p","q","r","s","t","u","v","w","x","y","z",
      }
    end,
  },

  -- aa / ia text objects for function arguments
  {
    "vim-scripts/argtextobj.vim",
    event = "VeryLazy",
  },
}
