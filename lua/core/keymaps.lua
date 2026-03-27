local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

-- Diagnostic navigation (Neovim 0.11+ API)
map("n", "]d", function() vim.diagnostic.jump({ count = 1 })  end, { silent = true, desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { silent = true, desc = "Prev diagnostic" })

-- Paste/delete without clobbering the unnamed register
map("x",         "<leader>p", [["_dP]], { silent = true, desc = "Paste without yanking" })
map({ "n", "x" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without yanking" })
