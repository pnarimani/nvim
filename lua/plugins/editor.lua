local function notify_git_history(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Git history" })
end

local function git_root_for(path)
  local out = vim.fn.systemlist({ "git", "-C", vim.fn.fnamemodify(path, ":h"), "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then return nil end
  return out[1]
end

local function relative_to(root, path)
  local prefix = root .. "/"
  if path:sub(1, #prefix) == prefix then return path:sub(#prefix + 1) end
  return path
end

local function open_git_range_history(bufnr, first_line, last_line)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    notify_git_history("Buffer is not backed by a file", vim.log.levels.ERROR)
    return
  end

  local root = git_root_for(file)
  if not root then
    notify_git_history("File is not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local start_line = math.min(first_line, last_line)
  local end_line = math.max(first_line, last_line)
  local rel_file = relative_to(root, vim.fn.fnamemodify(file, ":p"))
  local header = string.format("Git history for %s:%d-%d", rel_file, start_line, end_line)
  local log_spec = string.format("%d,%d:%s", start_line, end_line, rel_file)
  local lines = vim.fn.systemlist({ "git", "-C", root, "--no-pager", "log", "-p", "-L", log_spec })

  if vim.v.shell_error ~= 0 then
    notify_git_history(table.concat(lines, "\n"), vim.log.levels.ERROR)
    return
  end

  vim.cmd("tabnew")

  local history_buf = vim.api.nvim_get_current_buf()
  local content = { header, string.rep("=", #header), "" }
  vim.list_extend(content, lines)

  vim.bo[history_buf].buftype = "nofile"
  vim.bo[history_buf].bufhidden = "wipe"
  vim.bo[history_buf].swapfile = false
  vim.bo[history_buf].modifiable = true
  vim.bo[history_buf].filetype = "git"

  vim.api.nvim_buf_set_lines(history_buf, 0, -1, false, content)
  vim.bo[history_buf].modifiable = false

  vim.keymap.set("n", "q", "<cmd>tabclose<CR>", { buffer = history_buf, silent = true, desc = "Close git history" })
end

return {
  -- Fuzzy finder over files, grep, buffers, LSP, and more
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "if exist build rmdir /s /q build && cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -G \"MinGW Makefiles\" && cmake --build build" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      -- File / text search
      { "<leader>sf", function() require("telescope.builtin").find_files() end,                    desc = "Find files" },
      { "<leader>sg", function() require("telescope.builtin").live_grep() end,                     desc = "Live grep" },
      { "<leader>sw", function() require("telescope.builtin").grep_string() end,                   desc = "Grep word under cursor" },
      { "<leader>s/", function() require("telescope.builtin").current_buffer_fuzzy_find() end,     desc = "Search in buffer" },
      -- LSP symbols
      { "<leader>ss", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>sd", function() require("telescope.builtin").lsp_document_symbols() end,          desc = "Document symbols" },
      -- Buffers / recent
      { "<leader>sb", function() require("telescope.builtin").buffers() end,                       desc = "Buffers" },
      { "<leader>sr", function() require("telescope.builtin").oldfiles() end,                      desc = "Recent files" },
      -- Help / keymaps
      { "<leader>sh", function() require("telescope.builtin").help_tags() end,                     desc = "Help tags" },
      { "<leader>sk", function() require("telescope.builtin").keymaps() end,                       desc = "Keymaps" },
      -- Diagnostics
      { "<leader>se", function() require("telescope.builtin").diagnostics() end,                   desc = "Diagnostics" },
      -- Git
      { "<leader>sc", function() require("telescope.builtin").git_commits() end,                   desc = "Git commits" },
      { "<leader>sB", function() require("telescope.builtin").git_branches() end,                  desc = "Git branches" },
      { "<leader>st", function() require("telescope.builtin").git_status() end,                    desc = "Git status" },
      -- Resume last picker
      { "<leader>sR", function() require("telescope.builtin").resume() end,                        desc = "Resume last picker" },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup(vim.tbl_deep_extend("force", opts or {}, {
        defaults = {
          prompt_prefix    = "> ",
          selection_caret  = "> ",
          sorting_strategy = "ascending",
          layout_config    = { prompt_position = "top" },
          path_display     = { "truncate" },
          file_ignore_patterns = { "%.git/", "node_modules/", "%.DS_Store" },
          mappings = {
            i = {
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }))

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- Git change indicators, hunk actions, inline blame
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
      update_debounce     = 100,
      attach_to_untracked = false,
      current_line_blame  = false,
      current_line_blame_opts = {
        virt_text = true,
        delay     = 300,
      },
      on_attach = function(bufnr)
        local gs  = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
        end
        -- Hunk navigation
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        -- Staging and resetting
        map("n", "<leader>hs", gs.stage_hunk,      "Stage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hr", gs.reset_hunk,      "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer,    "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer,    "Reset buffer")
        -- Blame and diff
        map("n", "<leader>hb", gs.blame_line, "Blame line")
        map("n", "<leader>hB", function() gs.blame_line({ full = true }) end, "Blame (full)")
        map("n", "<leader>hd", gs.diffthis,    "Diff this")
        map("n", "<leader>hl", function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          open_git_range_history(bufnr, line, line)
        end, "Line history")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        -- Visual mode hunk operations
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>hl", function()
          open_git_range_history(bufnr, vim.fn.line("."), vim.fn.line("v"))
        end, "Selection history")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      end,
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
    event = "VeryLazy",
    opts  = {},
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
}
