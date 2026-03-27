return {
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },

      suggestion = {
        enabled                = true,
        auto_trigger           = true,
        hide_during_completion = true,
        trigger_on_accept      = true,
        debounce               = 15,
        keymap = {
          accept      = "<M-l>",
          accept_word = "<M-w>",
          accept_line = "<M-e>",
          next        = "<M-]>",
          prev        = "<M-[>",
          dismiss     = "<C-]>",
        },
      },

      -- NES: GitHub Copilot Next Edit Suggestions (normal mode)
      nes = {
        enabled      = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<M-Tab>",
          accept          = "<M-a>",
          dismiss         = "<M-/>",
        },
      },

      filetypes = {
        ["*"]       = true,
        markdown    = false,
        help        = false,
        gitcommit   = false,
        gitrebase   = false,
      },
    },
  },

  -- copilot-lsp: native LSP binary for NES
  {
    "copilotlsp-nvim/copilot-lsp",
    lazy = false,
    init = function()
      vim.g.copilot_nes_debounce = 500
      vim.lsp.enable("copilot_ls")
    end,
    config = function()
      require("copilot-lsp").setup({
        nes = {
          move_count_threshold = 3,
        },
      })

      -- <Tab> in normal mode: walk to NES suggestion start, or apply + jump to end
      vim.keymap.set("n", "<tab>", function()
        local state = vim.b[vim.api.nvim_get_current_buf()].nes_state
        if state then
          local nes = require("copilot-lsp.nes")
          local _ = nes.walk_cursor_start_edit()
            or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
          return nil
        else
          return "<C-i>"
        end
      end, { desc = "Accept Copilot NES suggestion", expr = true })

      -- <Esc> in normal mode: clear NES suggestion, or fall through
      vim.keymap.set("n", "<esc>", function()
        if not require("copilot-lsp.nes").clear() then
          return "<esc>"
        end
      end, { desc = "Clear Copilot NES or Esc", expr = true })
    end,
  },
}
