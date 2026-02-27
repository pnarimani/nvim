local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = true

-- Search
opt.incsearch  = true
opt.ignorecase = true
opt.smartcase  = true

-- Editing
opt.clipboard:append("unnamedplus")
opt.updatetime = 200
opt.timeoutlen = 300

-- Persistent undo (try standard locations in order)
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 1 then return true end
  local ok = pcall(vim.fn.mkdir, path, "p")
  return ok and vim.fn.isdirectory(path) == 1
end

for _, path in ipairs({
  vim.fn.stdpath("state")  .. "/undo",
  vim.fn.stdpath("data")   .. "/undo",
  vim.fn.stdpath("config") .. "/undo",
}) do
  if ensure_dir(path) then
    opt.undofile = true
    opt.undodir  = path
    break
  end
end
