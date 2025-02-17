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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.wrap = true
-- Set global indentation settings
vim.opt.expandtab = false   -- Use spaces instead of tabs
vim.opt.shiftwidth = 2     -- Number of spaces per indentation level
vim.opt.tabstop = 2        -- Number of spaces per tab
vim.opt.smartindent = true -- Enable smart indentation

-- vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:ver25"
vim.opt.virtualedit = "onemore"

-- Enable line numbers
vim.opt.number = true

-- Optional: Enable relative line numbers
vim.opt.relativenumber = true

vim.opt.showmode = false

-- Remap movement keys for normal mode
vim.keymap.set("n", "ö", "h", { noremap = true }) -- Left
vim.keymap.set("n", "å", "k", { noremap = true }) -- Up
vim.keymap.set("n", "ä", "j", { noremap = true }) -- Down
vim.keymap.set("n", "'", "l", { noremap = true }) -- Right

-- Remap movement keys for visual mode
vim.keymap.set("v", "ö", "h", { noremap = true }) -- Left
vim.keymap.set("v", "å", "k", { noremap = true }) -- Up
vim.keymap.set("v", "ä", "j", { noremap = true }) -- Down
vim.keymap.set("v", "'", "l", { noremap = true }) -- Right

-- Remap movement keys for insert mode (Ctrl + Key)
vim.keymap.set("i", "<C-ö>", "<Left>", { noremap = true }) -- Left
vim.keymap.set("i", "<C-å>", "<Up>", { noremap = true }) -- Up
vim.keymap.set("i", "<C-ä>", "<Down>", { noremap = true }) -- Down
vim.keymap.set("i", "<C-'>", "<Right>", { noremap = true }) -- Right

-- Remove default movement keys
vim.keymap.set("n", "h", "<Nop>", { noremap = true })
vim.keymap.set("n", "j", "<Nop>", { noremap = true })
vim.keymap.set("n", "k", "<Nop>", { noremap = true })
vim.keymap.set("n", "l", "<Nop>", { noremap = true })


vim.g.tmux_navigator_no_mappings = 1  -- Disable default mappings

-- Set Ctrl + Arrow Keys for navigation
vim.api.nvim_set_keymap("n", "<C-Left>", "<cmd>TmuxNavigateLeft<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Up>", "<cmd>TmuxNavigateUp<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Down>", "<cmd>TmuxNavigateDown<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Right>", "<cmd>TmuxNavigateRight<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { noremap = true, silent = true })

-- Split Window Bindings (like your Tmux setup)
-- Open Yazi in a Horizontal Split
vim.api.nvim_set_keymap("n", "<Leader>H", ":split | wincmd j | Yazi<CR>", { noremap = true, silent = true })

-- Open Yazi in a Vertical Split
vim.api.nvim_set_keymap("n", "<Leader>V", ":vsplit | wincmd l | Yazi<CR>", { noremap = true, silent = true })

-- Close Current Split
vim.api.nvim_set_keymap("n", "<Leader>q", ":close<CR>", { noremap = true, silent = true })


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  ui = {
    backdrop = 0, -- Full transparency (WezTerm controls it)
    throttle = 1000 / 120, -- Increase rendering speed to 120Hz
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Auto-open Yazi when Neovim starts in a directory
-- vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    local arg = vim.fn.argv(0) -- Get the first argument passed to Neovim
--    if arg == "" then
--      vim.cmd("Yazi") -- Open Yazi if no file is provided
--    elseif vim.fn.isdirectory(arg) == 1 then
--      vim.cmd("Yazi " .. arg) -- Open Yazi in the given directory
--    end
--  end,
--})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local args = vim.fn.argv() -- Get all arguments passed to Neovim
    if #args == 0 then
      -- No arguments, open Yazi
      vim.cmd("Yazi")
    elseif vim.fn.isdirectory(args[1]) == 1 then
      -- A directory was passed, open Yazi in that directory
      vim.cmd("Yazi " .. args[1])
    end
  end,
})