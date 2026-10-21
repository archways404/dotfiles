-- Loaded before lazy.nvim. LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
local opt = vim.opt

opt.cursorline = true
opt.cursorlineopt = "number" -- highlight only the current line number
opt.scrolloff = 8 -- keep context around the cursor
opt.colorcolumn = "100"
opt.wrap = false
opt.swapfile = false
opt.undofile = true -- persistent undo
opt.spelllang = { "en", "sv" } -- English + Swedish (sv downloads on first use)

-- Leader stays <Space> (LazyVim default) – same position on SE and US.

-- Load machine preferences before keymaps/plugins.
require("config.keyboard").setup()

-- tree-sitter-cli installed locally by the cross-platform installer.
local tools = vim.fn.stdpath("data") .. "/dotfiles-tools/bin"
vim.env.PATH = tools .. (vim.fn.has("win32") == 1 and ";" or ":") .. vim.env.PATH

-- Let the terminal supply transparency; avoid opaque popup shadows.
opt.pumblend = 0
opt.winblend = 0
opt.pumborder = "rounded"

-- Prefer the actual repository to language-server roots in monorepos.
vim.g.root_spec = { { ".git" }, "lsp", { "package.json", "pyproject.toml", "Cargo.toml", "go.mod" }, "cwd" }

-- Syntax-aware folds, closed on first opening a file.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = true
opt.foldlevel = 0
opt.foldlevelstart = 0
opt.foldcolumn = "1"
opt.fillchars:append({ foldopen = "▾", foldclose = "▸", foldsep = " " })
