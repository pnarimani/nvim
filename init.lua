-- ============================================================================
-- Startup: set leaders FIRST (before any plugin sees them)
-- ============================================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Enable Neovim's built-in Lua bytecode cache (measurably faster cold starts)
pcall(vim.loader.enable)

-- ============================================================================
-- Providers: disable remote providers we don't use (~10-30 ms saved each)
-- ============================================================================
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0

-- ============================================================================
-- Built-in plugins: disable everything we don't need
-- ============================================================================
for _, p in ipairs({
  "2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat",
  "matchit", "matchparen", "netrw", "netrwFileHandlers", "netrwPlugin",
  "netrwSettings", "rrhelper", "tar", "tarPlugin", "tohtml", "tutor",
  "zip", "zipPlugin",
}) do
  vim.g["loaded_" .. p] = 1
end

-- Enable filetype detection, then load filetype-specific plugins and indent rules.
vim.cmd("filetype on")
vim.cmd("filetype plugin indent on")

-- ============================================================================
-- Core options and keymaps (pure Lua, no plugins required)
-- ============================================================================
require("core.options")
require("core.keymaps")

-- ============================================================================
-- Lazy.nvim bootstrap
-- ============================================================================
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 1 then return true end
  local ok = pcall(vim.fn.mkdir, path, "p")
  return ok and vim.fn.isdirectory(path) == 1
end

local lazypath
for _, path in ipairs({
  vim.fn.stdpath("data")   .. "/lazy/lazy.nvim",
  vim.fn.stdpath("config") .. "/.lazy/lazy.nvim",
}) do
  if ensure_dir(vim.fn.fnamemodify(path, ":h")) then
    lazypath = path
    break
  end
end

if not lazypath then return end

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end

if not vim.uv.fs_stat(lazypath) then return end

vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then return end

-- ============================================================================
-- Plugins  (each file under lua/plugins/ returns a spec table)
-- ============================================================================
lazy.setup({
  { import = "plugins" },
}, {
  defaults         = { lazy = true },
  install          = { colorscheme = { "tokyonight" } },
  checker          = { enabled = false },
  change_detection = { notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat",
        "matchit", "matchparen", "netrw", "netrwFileHandlers", "netrwPlugin",
        "netrwSettings", "rrhelper", "tar", "tarPlugin", "tohtml", "tutor",
        "zip", "zipPlugin",
      },
    },
  },
})
