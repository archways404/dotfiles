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
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})


-- NEOVIDE SETUP
if vim.g.neovide then

-- Function to check if running on battery or plugged in
function is_on_battery()
  local handle
  local result
  
  -- Check if we're on macOS
  handle = io.popen("pmset -g batt | grep 'Battery Power'")
  result = handle:read("*a")
  handle:close()
  
  -- If result is non-empty, it means we're on battery
  if result ~= "" then
    return true
  else
    return false
  end
end


  -- Put anything you want to happen only in Neovide here
  vim.opt.linespace = 0
  vim.g.neovide_scale_factor = 0.75
  vim.g.neovide_padding_top = 25
  vim.g.neovide_padding_bottom = 25
  vim.g.neovide_padding_right = 25
  vim.g.neovide_padding_left = 25
  vim.g.neovide_theme = 'auto'
  vim.g.experimental_layer_grouping = false
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.cmd('cd /Users/archways404/Developer/')
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5

  vim.g.neovide_position_animation_length = 0.15
  vim.g.neovide_scroll_animation_length = 0.2

  vim.g.neovide_hide_mouse_when_typing = false
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_cursor_smooth_blink = true

  -- Enable line numbers
  vim.opt.number = true

  -- Optional: Enable relative line numbers
  -- vim.opt.relativenumber = true

  -- Set refresh rate based on power status
  if is_on_battery() then
    vim.g.neovide_refresh_rate = 60
    vim.g.neovide_no_idle = false
  else
    vim.g.neovide_refresh_rate = 144
    vim.g.neovide_no_idle = true
  end


  end

  -- Set Space as the leader key
  --vim.g.mapleader = " "
  --vim.g.maplocalleader = " "

  vim.o.showmode = false
  vim.opt.wrap = true

  -- Set global indentation settings
  vim.opt.expandtab = true   -- Use spaces instead of tabs
  vim.opt.shiftwidth = 2     -- Number of spaces per indentation level
  vim.opt.tabstop = 2        -- Number of spaces per tab
  vim.opt.smartindent = true -- Enable smart indentation

  -- vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:ver25"
  vim.opt.virtualedit = "onemore"


  -- CHECK OS AND SET SHELL
  local uname = vim.loop.os_uname()
  if uname.sysname == "Windows_NT" then
    -- Set shell options for Windows
    vim.o.shell = 'C:/"Program Files"/Git/bin/bash.exe'
    vim.o.shellcmdflag = "-s"
  elseif uname.sysname == "Darwin" then
  elseif uname.sysname == "Linux" then
  end