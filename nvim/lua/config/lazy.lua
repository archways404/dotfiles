-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ── Languages ────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- TS/JS/React (vtsls)
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.python" }, -- pyright + ruff
    { import = "lazyvim.plugins.extras.lang.go" }, -- gopls, gofumpt, goimports
    { import = "lazyvim.plugins.extras.lang.rust" }, -- rustaceanvim + crates.nvim
    { import = "lazyvim.plugins.extras.lang.clangd" }, -- C / C++
    { import = "lazyvim.plugins.extras.lang.cmake" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.sql" },
    { import = "lazyvim.plugins.extras.lang.git" },
    -- { import = "lazyvim.plugins.extras.lang.java" }, -- uncomment for Java (needs a JDK)

    -- ── Formatting / linting ─────────────────────────────────────
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.linting.eslint" },

    -- ── Debugging & tests (Rust, Go, Python, C++, JS) ────────────
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.test.core" },

    -- ── Editing quality of life ──────────────────────────────────
    { import = "lazyvim.plugins.extras.coding.mini-surround" }, -- gsa / gsd / gsr
    { import = "lazyvim.plugins.extras.coding.yanky" }, -- yank history: <leader>p
    { import = "lazyvim.plugins.extras.editor.mini-files" }, -- <leader>fm file browser
    { import = "lazyvim.plugins.extras.editor.inc-rename" }, -- live preview on <leader>cr
    { import = "lazyvim.plugins.extras.editor.dial" }, -- smarter <C-a>/<C-x>
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" }, -- color previews
    -- ── AI ───────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.ai.claudecode" }, -- Claude Code in a split, <leader>a…

    -- ── Workflow ─────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.util.rest" }, -- .http files: <leader>R…
    { import = "lazyvim.plugins.extras.util.octo" }, -- GitHub PRs/issues: <leader>gi / gp
    { import = "lazyvim.plugins.extras.editor.overseer" }, -- task runner: <leader>o…
    { import = "lazyvim.plugins.extras.editor.harpoon2" }, -- pin files: <leader>H, <leader>1-5
    { import = "lazyvim.plugins.extras.editor.outline" }, -- symbols panel: <leader>cs
    { import = "lazyvim.plugins.extras.ui.smear-cursor" }, -- cursor trail

    -- Your own plugins / overrides (lua/plugins/*.lua)
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
