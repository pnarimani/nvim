return {
  {
    "hrsh7th/nvim-cmp",
    event        = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "L3MON4D3/LuaSnip",
        -- jsregexp is optional; skip the build step on Windows where make is absent
        build   = vim.fn.has("win32") == 0 and "make install_jsregexp" or nil,
        version = "v2.*",
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp      = require("cmp")
      local luasnip  = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          -- Confirm only when explicitly selected (<CR> on blank closes menu)
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          -- Tab: cycle completion / expand-or-jump snippet
          ["<Tab>"]  = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),

        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- Disable ghost text – copilot.lua provides its own inline suggestions
        experimental = { ghost_text = false },
      })

      -- Hide copilot inline suggestions while the cmp popup is open
      cmp.event:on("menu_opened", function() vim.b.copilot_suggestion_hidden = true  end)
      cmp.event:on("menu_closed", function() vim.b.copilot_suggestion_hidden = false end)

      cmp.setup.filetype({ "markdown", "text" }, {
        enabled = false,
      })
    end,
  },
}
