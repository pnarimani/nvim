return {
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    -- copilot-lsp is required for NES (Next Edit Suggestions)
    dependencies = { "copilotlsp-nvim/copilot-lsp" },
    opts = {
      panel = { enabled = false }, -- inline suggestions only; panel wastes screen space

      suggestion = {
        enabled             = true,
        auto_trigger        = true,
        hide_during_completion = true,
        debounce            = 15,
        keymap = {
          accept      = "<M-l>",  -- accept the whole suggestion
          accept_word = "<M-w>",  -- accept one word at a time
          accept_line = "<M-e>",  -- accept one line at a time
          next        = "<M-]>",
          prev        = "<M-[>",
          dismiss     = "<C-]>",
        },
      },

      -- NES: GitHub Copilot Next Edit Suggestions
      -- Watches your recent edits and proactively suggests the next edit site.
      nes = {
        enabled      = true,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<M-Tab>", -- jump to the suggested next edit and apply it
          accept          = "<M-a>",
          dismiss         = "<M-/>",
        },
      },

      filetypes = { ["*"] = true },
    },
  },
}
