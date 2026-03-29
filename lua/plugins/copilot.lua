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

      filetypes = {
        ["*"]       = true,
        markdown    = false,
        text        = false,
        help        = false,
        gitcommit   = false,
        gitrebase   = false,
      },
    },
  },

}
