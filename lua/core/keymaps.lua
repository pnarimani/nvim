local map = vim.keymap.set

-- Built-in undo tree (Neovim 0.12+)
map("n", "<leader>u", "<cmd>Undotree<CR>", { silent = true, desc = "Undotree" })

-- Paste/delete without clobbering the unnamed register
map("x",         "<leader>p", [["_dP]], { silent = true, desc = "Paste without yanking" })
map({ "n", "x" }, "<leader>d", [["_d]], { silent = true, desc = "Delete without yanking" })
