return {
  {
    "folke/sidekick.nvim",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    opts = {},
    keys = {
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        mode = { "n", "t" },
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        mode = { "n", "t" },
        desc = "Sidekick Select CLI",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        mode = { "n", "t" },
        desc = "Sidekick Detach CLI",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Prompt",
      },
    },
  },
}
