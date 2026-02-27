local map = vim.keymap.set

-- Window navigation
map("n", "<C-c>", "<Esc>",   { silent = true })
map("n", "<C-h>", "<C-w>h",  { silent = true })
map("n", "<C-j>", "<C-w>j",  { silent = true })
map("n", "<C-k>", "<C-w>k",  { silent = true })
map("n", "<C-l>", "<C-w>l",  { silent = true })

-- Diagnostic navigation (mirrors ]d / [d / <leader>q in ideavimrc → GotoNextError)
map("n", "]d",        function() vim.diagnostic.goto_next() end, { silent = true, desc = "Next diagnostic" })
map("n", "[d",        function() vim.diagnostic.goto_prev() end, { silent = true, desc = "Prev diagnostic" })
map("n", "<leader>q", function() vim.diagnostic.goto_next() end, { silent = true, desc = "Next diagnostic" })

-- Paste/delete without clobbering the unnamed register
map("x",        "<leader>p", [["_dP]], { silent = true, desc = "Paste without yanking" })
map({ "n","x" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without yanking" })

-- Indentation
map("n", "<leader>vo", "<<", { silent = true, desc = "Shift left" })
map("n", "ml",         ">>", { silent = true, desc = "Shift right" })
