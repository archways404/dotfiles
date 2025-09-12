return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for async processes
  },
  cmd = "LazyGit", -- Only loads when running `:LazyGit`
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" }, -- Keybinding for quick access
    { "<leader>gl", "<cmd>LazyGitCurrentFile<CR>", desc = "LazyGit Blame/Log" },
  },
  config = function()
    -- Optional: Override settings for LazyGit
    vim.g.lazygit_floating_window_winblend = 0 -- Transparency (0 = opaque)
    vim.g.lazygit_floating_window_scaling_factor = 1 -- Default scaling
    vim.g.lazygit_floating_window_border_chars = { "╭", "╮", "╰", "╯", "─", "│", "│", "│" } -- Borders
    vim.g.lazygit_floating_window_use_plenary = 0 -- Don't force plenary.nvim
    vim.g.lazygit_use_neovim_remote = 1 -- Use nvim-remote for keybinds
  end,
}